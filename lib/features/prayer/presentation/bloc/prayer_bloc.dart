import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/services/prayer_scheduler_service.dart';
import '../../../../core/services/prayer_time_service.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/usecases/log_prayer_usecase.dart';
import '../../domain/usecases/get_daily_status_usecase.dart';
import '../../domain/usecases/get_streak_usecase.dart';
import '../../domain/usecases/get_weekly_history_usecase.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';
import 'settings/settings_bloc.dart';
import 'settings/settings_event.dart';
import 'settings/settings_state.dart';
/// PrayerBloc — orchestrates domain use cases and delegates GPS/notification
/// work to PrayerSchedulerService.
class PrayerBloc extends HydratedBloc<PrayerEvent, PrayerState> {
  final LogPrayerUseCase logPrayerUseCase;
  final GetDailyStatusUseCase getDailyStatusUseCase;
  final GetStreakUseCase getStreakUseCase;
  final GetWeeklyHistoryUseCase getWeeklyHistoryUseCase;
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
    if (state.prayers.isEmpty) {
      emit(state.copyWith(
        prayers: Prayer.defaultPrayers(),
        isLoading: true,
      ));
    }

    // Seed cached coordinates from persisted state so they're available
    // before GPS resolves (allows instant recalc on method change).
    prayerSchedulerService.seedCachedCoordinates(
      state.cachedLat,
      state.cachedLng,
    );

    // Check current permission status (non-prompting) so SettingsState is correct.
    final hasPerms = await notificationService.checkPermissions();
    if (hasPerms != settingsBloc.state.notificationsPermitted) {
      settingsBloc.add(UpdateGlobalNotificationSettings(notificationsPermitted: hasPerms));
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
        final isOldDefault = settingsBloc.state.calculationMethod == 'ISNA' ||
            settingsBloc.state.calculationMethod == 'MWL';
        if (isOldDefault && lat != null && lng != null) {
          final detectedMethod = PrayerTimeService.methodFromCoordinates(lat, lng);
          settingsBloc.add(UpdateCalculationSettings(
            calculationMethod: detectedMethod,
            methodAutoDetected: true,
          ));
          debugPrint(
              '[PrayerBloc] Auto-detected method: $detectedMethod '
              'for ($lat, $lng)');
        }
      }

      emit(state.copyWith(
        prayers: result.prayers,
        cachedLat: lat,
        cachedLng: lng,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false));
    }

    // 2. Try to sync completion status with server
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
          );
        }
        return local;
      }).toList();

      // Sync streak and history
      final streak = await getStreakUseCase();
      final history = await getWeeklyHistoryUseCase(days: 90);

      // Reconstruct missing historicalLog entries from the backend summary.
      // We do not overwrite existing local records as they possess richer data 
      // (exact time, inJamaat, location, etc.).
      final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
      
      history.forEach((dateString, completedCount) {
        if (!updatedLog.containsKey(dateString)) {
          final names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
          final List<Prayer> syntheticPrayers = [];
          for (int i = 0; i < 5; i++) {
            // Create dummy prayers just so the renderer has completed statuses
            syntheticPrayers.add(Prayer(
              name: names[i],
              timeRange: '', // Ignored by progress renderer
              isCompleted: i < completedCount,
            ));
          }
          updatedLog[dateString] = syntheticPrayers;
        }
      });

      emit(state.copyWith(
        prayers: merged,
        streak: streak,
        historicalLog: updatedLog,
      ));
    } catch (e) {
      debugPrint('[PrayerBloc] Server sync failed (likely offline): $e');
    }
  }

  Future<void> _onLogPrayer(
    LogPrayer event,
    Emitter<PrayerState> emit,
  ) async {
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

    // 2. Optimistic streak update
    final completedCount =
        updatedPrayers.where((p) => p.isCompleted).length;
    var updatedStreak = state.streak;
    if (completedCount == 5) {
      updatedStreak = state.streak.copyWith(
        currentStreak: state.streak.currentStreak + 1,
      );
    }

    // 3. Update historical log with full details
    final updatedLog = Map<String, List<Prayer>>.from(state.historicalLog);
    updatedLog[PrayerState.todayKey] = updatedPrayers;

    emit(state.copyWith(
      prayers: updatedPrayers,
      streak: updatedStreak,
      historicalLog: updatedLog,
      syncStatus: SyncStatus.syncing,
    ));

    // 4. Sync with backend
    try {
      await logPrayerUseCase(
        prayerName: event.prayerName,
        completed: event.completed,
        inJamaat: event.inJamaat,
        location: event.location,
      );
      emit(state.copyWith(syncStatus: SyncStatus.synced));
    } catch (e) {
      await offlineSyncService.enqueueAction(
        prayerName: event.prayerName,
        completed: event.completed,
        inJamaat: event.inJamaat,
        location: event.location,
      );
      emit(state.copyWith(syncStatus: SyncStatus.error));
    }
  }

  void _onToggleJamaat(
    ToggleJamaat event,
    Emitter<PrayerState> emit,
  ) {
    final updatedPrayers = state.prayers.map((prayer) {
      if (prayer.name.toLowerCase() == event.prayerName.toLowerCase()) {
        return prayer.copyWith(inJamaat: !prayer.inJamaat);
      }
      return prayer;
    }).toList();

    emit(state.copyWith(prayers: updatedPrayers));
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
      emit(state.copyWith(
        prayers: prayers,
        syncStatus: SyncStatus.synced,
      ));
    } catch (e) {
      emit(state.copyWith(syncStatus: SyncStatus.error));
    }
  }

  Future<void> _onRefreshPrayersAndAlarms(
    RefreshPrayersAndAlarms event,
    Emitter<PrayerState> emit,
  ) async {
    final result = await prayerSchedulerService.refreshPrayersAndAlarms(
      currentPrayers: state.prayers,
      settingsState: settingsBloc.state,
      cachedLat: state.cachedLat,
      cachedLng: state.cachedLng,
    );

    if (result != null) {
      emit(state.copyWith(
        prayers: result.prayers,
        cachedLat: result.lat,
        cachedLng: result.lng,
      ));
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
