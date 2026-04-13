import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/offline_sync_service.dart';
import '../../../../../core/services/prayer_scheduler_service.dart';
import '../../../../../core/services/prayer_time_service.dart';
import '../../../domain/entities/prayer.dart';
import '../../../domain/usecases/log_prayer_usecase.dart';
import '../../../domain/usecases/get_daily_status_usecase.dart';
import '../../../domain/usecases/get_streak_usecase.dart';
import '../../../domain/usecases/get_weekly_history_usecase.dart';
import '../../../domain/usecases/get_detailed_month_history_usecase.dart';
import '../../../domain/usecases/get_reason_summary_usecase.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';
import '../settings/settings_bloc.dart';
import '../settings/settings_event.dart';
import '../settings/settings_state.dart';

/// PrayerBloc — orchestrates domain use cases and delegates GPS/notification
/// work to PrayerSchedulerService.
class PrayerBloc extends HydratedBloc<PrayerEvent, PrayerState> {
  final LogPrayerUseCase logPrayerUseCase;
  final GetDailyStatusUseCase getDailyStatusUseCase;
  final GetStreakUseCase getStreakUseCase;
  final GetWeeklyHistoryUseCase getWeeklyHistoryUseCase;
  final GetDetailedMonthHistoryUseCase getDetailedMonthHistoryUseCase;
  final GetReasonSummaryUseCase getReasonSummaryUseCase;
  final OfflineSyncService offlineSyncService;
  final PrayerSchedulerService prayerSchedulerService;
  final NotificationService notificationService;
  final SettingsBloc settingsBloc;

  late final StreamSubscription<SettingsState> _settingsSubscription;

  PrayerBloc({
    required this.logPrayerUseCase,
    required this.getDailyStatusUseCase,
    required this.getStreakUseCase,
    required this.getWeeklyHistoryUseCase,
    required this.getDetailedMonthHistoryUseCase,
    required this.getReasonSummaryUseCase,
    required this.offlineSyncService,
    required this.prayerSchedulerService,
    required this.notificationService,
    required this.settingsBloc,
  }) : super(PrayerState(prayers: Prayer.defaultPrayers())) {
    on<LoadDailyStatus>(_onLoadDailyStatus);
    on<LogPrayer>(_onLogPrayer, transformer: droppable());
    on<ToggleJamaat>(_onToggleJamaat);
    on<SetPrayerLocation>(_onSetPrayerLocation);
    on<SyncWithServer>(_onSyncWithServer);
    on<RefreshPrayersAndAlarms>(_onRefreshPrayersAndAlarms);
    on<LoadMonthHistory>(_onLoadMonthHistory);
    on<LoadAllReasons>(_onLoadAllReasons);
    on<SelectDate>(_onSelectDate);

    _settingsSubscription = settingsBloc.stream.listen((_) {
      add(const RefreshPrayersAndAlarms());
    });
  }

  @override
  Future<void> close() {
    _settingsSubscription.cancel();
    return super.close();
  }

  Future<void> _onLoadDailyStatus(
    LoadDailyStatus event,
    Emitter<PrayerState> emit,
  ) async {
    // 0. Ensure 'prayers' list in state matches today's entry in historical log.
    // This handles the case where midnight has passed and we need to reset the 
    // "active" prayers list to uncompleted status for the new day.
    final todayLog = state.historicalLog[PrayerState.todayKey];
    if (todayLog != null) {
      emit(state.copyWith(prayers: todayLog));
    } else {
      // Clear today's active list for the brand new day
      emit(state.copyWith(prayers: Prayer.defaultPrayers()));
    }

    emit(state.copyWith(isLoading: true));

    // Seed cached coordinates from persisted state so they're available
    // before GPS resolves (allows instant recalc on method change).
    prayerSchedulerService.seedCachedCoordinates(
      state.cachedLat,
      state.cachedLng,
    );

    // Check current permission status (non-prompting) so SettingsState is correct.
    final hasPerms = await notificationService.checkPermissions();
    if (hasPerms != settingsBloc.state.notificationsPermitted) {
      settingsBloc.add(
        UpdateGlobalNotificationSettings(notificationsPermitted: hasPerms),
      );
    }

    // 1. Single GPS call → calculate times + schedule notifications
    final result = await prayerSchedulerService.refreshPrayersAndAlarms(
      currentPrayers: state.prayers,
      settingsState: settingsBloc.state,
      cachedLat: state.cachedLat,
      cachedLng: state.cachedLng,
    );
    if (result != null) {
      final lat = result.lat;
      final lng = result.lng;

      // Auto-detect regional calculation method if not detected before
      if (!settingsBloc.state.methodAutoDetected) {
        final isOldDefault =
            settingsBloc.state.calculationMethod == 'ISNA' ||
            settingsBloc.state.calculationMethod == 'MWL';
        if (isOldDefault && lat != null && lng != null) {
          final detectedMethod = PrayerTimeService.methodFromCoordinates(
            lat,
            lng,
          );
          settingsBloc.add(
            UpdateCalculationSettings(
              calculationMethod: detectedMethod,
              methodAutoDetected: true,
            ),
          );
          debugPrint(
            '[PrayerBloc] Auto-detected method: $detectedMethod '
            'for ($lat, $lng)',
          );
        }
      }

      emit(
        state.copyWith(
          prayers: result.prayers,
          cachedLat: lat,
          cachedLng: lng,
          isLoading: false,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false));
    }

    // 2. Sync today's status with server — merging full details (status, reason)
    try {
      final serverPrayers = await getDailyStatusUseCase();
      final currentPrayers = state.prayers;
      final merged = currentPrayers.map((local) {
        final server = serverPrayers.where(
          (s) => s.name.toLowerCase() == local.name.toLowerCase(),
        );
        if (server.isNotEmpty) {
          return local.copyWith(
            isCompleted: server.first.isCompleted,
            inJamaat: server.first.inJamaat,
            status: server.first.status,
            reason: server.first.reason,
          );
        }
        return local;
      }).toList();

      // Sync streak
      final streak = await getStreakUseCase();

      // Update today's entry in historicalLog with merged data
      final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
      updatedLog[PrayerState.todayKey] = merged;

      emit(
        state.copyWith(
          prayers: merged,
          streak: streak,
          historicalLog: updatedLog,
        ),
      );
    } catch (e) {
      debugPrint('[PrayerBloc] Server sync failed (likely offline): $e');
    }

    // 3. Fetch detailed history for the current effective calendar month
    final effectiveNow = DateTime.now();
    add(LoadMonthHistory(year: effectiveNow.year, month: effectiveNow.month));

    // 4. Fetch aggregated reason counts
    add(const LoadAllReasons());
  }

  Future<void> _onLogPrayer(LogPrayer event, Emitter<PrayerState> emit) async {
    final effectiveDateKey = state.selectedDateStr ?? PrayerState.todayKey;
    final isToday = effectiveDateKey == PrayerState.todayKey;

    // 1. Optimistic local update
    final updatedPrayers = state.displayPrayers.map((prayer) {
      if (prayer.name.toLowerCase() == event.prayerName.toLowerCase()) {
        return prayer.copyWith(
          isCompleted: event.completed,
          inJamaat: event.inJamaat,
          location: event.location,
          status: event.status,
          reason: event.reason,
        );
      }
      return prayer;
    }).toList();

    // 2. Update historical log with full details
    final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
    updatedLog[effectiveDateKey] = updatedPrayers;

    // 3. Optimistic streak recalculation from local data
    //    Build a temporary state with the updated prayers + log so the
    //    streak helper sees the freshest data.
    final tempState = state.copyWith(
      prayers: isToday ? updatedPrayers : state.prayers,
      historicalLog: updatedLog,
    );
    final updatedStreak = tempState.calculateOptimisticStreak();

    // 4. Optimistic update of reasonCounts for instant UI feedback
    var updatedReasonCounts = Map<String, int>.from(state.reasonCounts);
    if ((event.status == 'late' || event.status == 'missed') &&
        event.reason != null) {
      updatedReasonCounts[event.reason!] =
          (updatedReasonCounts[event.reason!] ?? 0) + 1;
    }

    emit(
      state.copyWith(
        prayers: isToday ? updatedPrayers : state.prayers,
        streak: updatedStreak,
        historicalLog: updatedLog,
        reasonCounts: updatedReasonCounts,
        syncStatus: SyncStatus.syncing,
      ),
    );

    // 5. Sync with backend
    try {
      await logPrayerUseCase(
        prayerName: event.prayerName,
        completed: event.completed,
        inJamaat: event.inJamaat,
        location: event.location,
        status: event.status,
        reason: event.reason,
        dateKey: isToday ? null : effectiveDateKey,
      );

      // Re-fetch the authoritative streak from the server after recalculation
      try {
        final updatedStreak = await getStreakUseCase();
        emit(state.copyWith(streak: updatedStreak, syncStatus: SyncStatus.synced));
      } catch (_) {
        emit(state.copyWith(syncStatus: SyncStatus.synced));
      }
    } catch (e) {
      await offlineSyncService.enqueueAction(
        prayerName: event.prayerName,
        completed: event.completed,
        inJamaat: event.inJamaat,
        location: event.location,
        status: event.status,
        reason: event.reason,
        dateKey: isToday ? null : effectiveDateKey,
      );
      emit(state.copyWith(syncStatus: SyncStatus.error));
    }
  }

  void _onSelectDate(SelectDate event, Emitter<PrayerState> emit) {
    emit(state.copyWith(selectedDateStr: event.date));
  }

  void _onToggleJamaat(ToggleJamaat event, Emitter<PrayerState> emit) {
    final effectiveDateKey = state.selectedDateStr ?? PrayerState.todayKey;
    final isToday = effectiveDateKey == PrayerState.todayKey;

    final updatedPrayers = state.displayPrayers.map((prayer) {
      if (prayer.name.toLowerCase() == event.prayerName.toLowerCase()) {
        return prayer.copyWith(inJamaat: !prayer.inJamaat);
      }
      return prayer;
    }).toList();

    final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
    updatedLog[effectiveDateKey] = updatedPrayers;

    emit(state.copyWith(
      prayers: isToday ? updatedPrayers : state.prayers,
      historicalLog: updatedLog,
    ));
  }

  void _onSetPrayerLocation(
    SetPrayerLocation event,
    Emitter<PrayerState> emit,
  ) {
    emit(state.copyWith(selectedLocation: event.location));
  }

  Future<void> _onSyncWithServer(
    SyncWithServer event,
    Emitter<PrayerState> emit,
  ) async {
    emit(state.copyWith(syncStatus: SyncStatus.syncing));
    try {
      final prayers = await getDailyStatusUseCase();
      emit(state.copyWith(prayers: prayers, syncStatus: SyncStatus.synced));
    } catch (e) {
      emit(state.copyWith(syncStatus: SyncStatus.error));
    }
  }

  Future<void> _onRefreshPrayersAndAlarms(
    RefreshPrayersAndAlarms event,
    Emitter<PrayerState> emit,
  ) async {
    final settings = settingsBloc.state;

    // Always ensure the scheduler has coordinates from persisted state.
    // This covers hot-restart and edge cases where the service cache is empty.
    if (prayerSchedulerService.cachedCoordinates == null &&
        state.cachedLat != null &&
        state.cachedLng != null) {
      prayerSchedulerService.seedCachedCoordinates(
        state.cachedLat,
        state.cachedLng,
      );
    }

    // If still no coordinates, do a full GPS refresh instead
    if (prayerSchedulerService.cachedCoordinates == null) {
      debugPrint(
        '[PrayerBloc] No cached coords — falling back to full GPS refresh',
      );
      final result = await prayerSchedulerService.refreshPrayersAndAlarms(
        currentPrayers: state.prayers,
        settingsState: settings,
        cachedLat: state.cachedLat,
        cachedLng: state.cachedLng,
      );
      if (result != null) {
        emit(
          state.copyWith(
            prayers: result.prayers,
            cachedLat: result.lat,
            cachedLng: result.lng,
          ),
        );
      }
      return;
    }

    // Fast path: use cached coordinates for instant recalculation
    final updatedPrayers = prayerSchedulerService.recalculateWithCachedCoords(
      currentPrayers: state.prayers,
      methodName: settings.calculationMethod,
      useHanafi: settings.useHanafi,
      manualOffsets: settings.manualOffsets,
    );

    debugPrint(
      '[PrayerBloc] Recalculated prayers with offsets: ${settings.manualOffsets}',
    );
    emit(state.copyWith(prayers: updatedPrayers));

    // Reschedule notifications in the background
    await prayerSchedulerService.scheduleNotifications(settings);
  }

  /// Fetch detailed prayer history for a specific month.
  /// Smart caching: skips fetch if data already loaded (unless it's the current month).
  Future<void> _onLoadMonthHistory(
    LoadMonthHistory event,
    Emitter<PrayerState> emit,
  ) async {
    final monthKey = '${event.year}-${event.month.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final isCurrentMonth = event.year == now.year && event.month == now.month;

    // Update calendar navigation immediately
    emit(state.copyWith(calendarYear: event.year, calendarMonth: event.month));

    // Skip if already fetched (and not current month — current month always refreshes)
    if (state.fetchedMonths.contains(monthKey) && !isCurrentMonth) {
      return;
    }

    try {
      final monthData = await getDetailedMonthHistoryUseCase(
        year: event.year,
        month: event.month,
      );

      // Merge into historicalLog (backend data takes priority for historical months,
      // but for current month we preserve today's local state)
      final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
      monthData.forEach((dateStr, prayers) {
        if (isCurrentMonth && dateStr == PrayerState.todayKey) {
          // Don't overwrite today's optimistic local state
          return;
        }
        updatedLog[dateStr] = prayers;
      });

      final updatedFetched = Set<String>.from(state.fetchedMonths)
        ..add(monthKey);

      emit(
        state.copyWith(
          historicalLog: updatedLog,
          fetchedMonths: updatedFetched,
        ),
      );

      // Recalculate streak — new month data may connect streak segments
      final recalcStreak = state.copyWith(
        historicalLog: updatedLog,
      ).calculateOptimisticStreak();
      emit(state.copyWith(streak: recalcStreak));
    } catch (e) {
      debugPrint('[PrayerBloc] Failed to load month history for $monthKey: $e');
    }
  }

  /// Fetch aggregated reason counts from backend.
  Future<void> _onLoadAllReasons(
    LoadAllReasons event,
    Emitter<PrayerState> emit,
  ) async {
    try {
      final reasons = await getReasonSummaryUseCase();
      emit(state.copyWith(reasonCounts: reasons));
    } catch (e) {
      debugPrint('[PrayerBloc] Failed to load reason summary: $e');
    }
  }

  // ── HydratedBloc overrides ──

  @override
  PrayerState? fromJson(Map<String, dynamic> json) {
    try {
      return PrayerState.fromJson(json);
    } catch (e) {
      debugPrint('[PrayerBloc] Failed to restore state from JSON: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PrayerState state) {
    try {
      return state.toJson();
    } catch (e) {
      debugPrint('[PrayerBloc] Failed to serialize state to JSON: $e');
      return null;
    }
  }
}
