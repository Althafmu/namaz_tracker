import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:intl/intl.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/offline_sync_service.dart';
import '../../../../../core/services/prayer_scheduler_service.dart';
import '../../../../../core/services/prayer_time_service.dart';
import '../../../../../core/services/time_service.dart';
import '../../../domain/entities/prayer.dart';
import '../../../domain/usecases/log_prayer_usecase.dart';
import '../../../domain/usecases/get_daily_status_usecase.dart';
import '../../../domain/usecases/undo_last_prayer_log_usecase.dart';
import '../history/history_bloc.dart';
import '../history/history_event.dart';
import '../stats/stats_bloc.dart';
import '../stats/stats_event.dart';
import '../settings/settings_bloc.dart';
import '../settings/settings_event.dart';
import '../settings/settings_state.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

/// PrayerBloc — manages today's prayers and coordinates other BLoCs.
/// Historical data is delegated to HistoryBloc.
/// Statistics are delegated to StatsBloc.
/// Streak is managed by StreakBloc.
class PrayerBloc extends HydratedBloc<PrayerEvent, PrayerState> {
  final LogPrayerUseCase logPrayerUseCase;
  final GetDailyStatusUseCase getDailyStatusUseCase;
  final UndoLastPrayerLogUseCase? undoLastPrayerLogUseCase;
  final OfflineSyncService offlineSyncService;
  final PrayerSchedulerService prayerSchedulerService;
  final NotificationService notificationService;
  final SettingsBloc settingsBloc;
  final HistoryBloc historyBloc;
  final StatsBloc statsBloc;

  late final StreamSubscription<SettingsState> _settingsSubscription;

  PrayerBloc({
    required this.logPrayerUseCase,
    required this.getDailyStatusUseCase,
    this.undoLastPrayerLogUseCase,
    required this.offlineSyncService,
    required this.prayerSchedulerService,
    required this.notificationService,
    required this.settingsBloc,
    required this.historyBloc,
    required this.statsBloc,
  }) : super(PrayerState(prayers: Prayer.defaultPrayers())) {
    on<LoadDailyStatus>(_onLoadDailyStatus);
    on<LogPrayer>(_onLogPrayer, transformer: droppable());
    on<ToggleJamaat>(_onToggleJamaat);
    on<SetPrayerLocation>(_onSetPrayerLocation);
    on<SyncWithServer>(_onSyncWithServer);
    on<RefreshPrayersAndAlarms>(_onRefreshPrayersAndAlarms);
    on<UndoLastPrayerLog>(_onUndoLastPrayerLog);

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
    emit(state.copyWith(isLoading: true));

    // Seed cached coordinates from persisted state
    prayerSchedulerService.seedCachedCoordinates(
      state.cachedLat,
      state.cachedLng,
    );

    // Check current permission status
    final hasPerms = await notificationService.checkPermissions();
    if (hasPerms != settingsBloc.state.notificationsPermitted) {
      settingsBloc.add(
        UpdateGlobalNotificationSettings(notificationsPermitted: hasPerms),
      );
    }

    // 1. GPS call → calculate times + schedule notifications
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

    // 2. Sync today's status with server
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
            recoveryState: server.first.recoveryState,
          );
        }
        return local;
      }).toList();

      // Update today in HistoryBloc
      final todayKey = DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());
      historyBloc.add(UpdateDayLog(dateStr: todayKey, prayers: merged));

      emit(state.copyWith(prayers: merged));
    } on NetworkException catch (e) {
      // Offline - use cached state, mark as sync error
      debugPrint('[PrayerBloc] Network error during sync: ${e.message}');
      // State already has optimistic updates from HydratedBloc
    } on ServerException catch (e) {
      // Server error - log but don't crash, use cached state
      debugPrint('[PrayerBloc] Server error during sync (${e.statusCode}): ${e.message}');
    } on NoDataException catch (e) {
      // No data - use defaults
      debugPrint('[PrayerBloc] No data: ${e.message}');
    } catch (e) {
      debugPrint('[PrayerBloc] Unexpected error during sync: $e');
    }

    // 3. Trigger history and stats loading in their respective BLoCs
    final effectiveNow = TimeService.effectiveNow();
    historyBloc.add(LoadMonthHistory(
      year: effectiveNow.year,
      month: effectiveNow.month,
    ));
    statsBloc.add(const LoadAllReasons());
  }

  Future<void> _onLogPrayer(LogPrayer event, Emitter<PrayerState> emit) async {
    // Get the selected date from HistoryBloc
    final effectiveDateKey = historyBloc.state.selectedDateStr ??
        DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());
    final isToday = effectiveDateKey == DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());

    // 1. Optimistic local update
    final updatedPrayers = state.prayers.map((prayer) {
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

    // 2. Update HistoryBloc
    final historyPrayers = isToday
        ? updatedPrayers
        : (historyBloc.state.historicalLog[effectiveDateKey] ?? Prayer.defaultPrayers());

    if (!isToday) {
      final updatedHistoryPrayers = historyPrayers.map((prayer) {
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
      historyBloc.add(UpdateDayLog(dateStr: effectiveDateKey, prayers: updatedHistoryPrayers));
    } else {
      historyBloc.add(UpdateDayLog(dateStr: effectiveDateKey, prayers: updatedPrayers));
    }

    // 3. Optimistic update
    final tempPrayers = isToday ? updatedPrayers : state.prayers;
    emit(state.copyWith(prayers: tempPrayers, syncStatus: SyncStatus.syncing));

    // 4. Update StatsBloc if reason provided
    if ((event.status == 'late' || event.status == 'missed') &&
        event.reason != null) {
      statsBloc.add(UpdateReason(reason: event.reason!, delta: 1));
    }

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
      emit(state.copyWith(syncStatus: SyncStatus.synced));
    } on NetworkException catch (e) {
      // Offline - enqueue for later sync
      debugPrint('[PrayerBloc] Network error during log: ${e.message}');
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
    } on ServerException catch (e) {
      // Server error - enqueue for retry
      debugPrint('[PrayerBloc] Server error during log (${e.statusCode}): ${e.message}');
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
    } catch (e) {
      debugPrint('[PrayerBloc] Unexpected error during log: $e');
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

  void _onToggleJamaat(ToggleJamaat event, Emitter<PrayerState> emit) {
    final effectiveDateKey = historyBloc.state.selectedDateStr ??
        DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());
    final isToday = effectiveDateKey == DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());

    final updatedPrayers = state.prayers.map((prayer) {
      if (prayer.name.toLowerCase() == event.prayerName.toLowerCase()) {
        return prayer.copyWith(inJamaat: !prayer.inJamaat);
      }
      return prayer;
    }).toList();

    if (isToday) {
      emit(state.copyWith(prayers: updatedPrayers));
      historyBloc.add(UpdateDayLog(dateStr: effectiveDateKey, prayers: updatedPrayers));
    }
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

    if (prayerSchedulerService.cachedCoordinates == null &&
        state.cachedLat != null &&
        state.cachedLng != null) {
      prayerSchedulerService.seedCachedCoordinates(
        state.cachedLat,
        state.cachedLng,
      );
    }

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

    await prayerSchedulerService.scheduleNotifications(settings);
  }

  Future<void> _onUndoLastPrayerLog(
    UndoLastPrayerLog event,
    Emitter<PrayerState> emit,
  ) async {
    if (undoLastPrayerLogUseCase == null) {
      emit(state.copyWith(
        undoStatus: UndoStatus.error,
        lastActionMessage: 'Undo is not available.',
      ));
      return;
    }

    emit(state.copyWith(undoStatus: UndoStatus.loading));

    try {
      final targetDateKey =
          event.dateKey ??
          DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());
      final todayKey = DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());
      final isToday = targetDateKey == todayKey;
      final updatedPrayers = await undoLastPrayerLogUseCase!(
        prayerName: event.prayerName,
        dateKey: targetDateKey,
      );
      historyBloc.add(UpdateDayLog(dateStr: targetDateKey, prayers: updatedPrayers));

      emit(state.copyWith(
        prayers: isToday ? updatedPrayers : state.prayers,
        undoStatus: UndoStatus.success,
        lastActionMessage: event.prayerName != null
            ? '${event.prayerName} log removed.'
            : 'Last prayer log undone successfully.',
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        undoStatus: UndoStatus.error,
        lastActionMessage: e.userMessage,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        undoStatus: UndoStatus.error,
        lastActionMessage: 'Network error. Please check your connection.',
      ));
      debugPrint('[PrayerBloc] Network error during undo: ${e.message}');
    } catch (e) {
      emit(state.copyWith(
        undoStatus: UndoStatus.error,
        lastActionMessage: 'Failed to undo. Please try again.',
      ));
      debugPrint('[PrayerBloc] Unexpected error during undo: $e');
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