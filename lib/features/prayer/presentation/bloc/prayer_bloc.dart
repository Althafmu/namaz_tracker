import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/services/prayer_scheduler_service.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/usecases/log_prayer_usecase.dart';
import '../../domain/usecases/get_daily_status_usecase.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

/// PrayerBloc — orchestrates domain use cases and delegates GPS/notification
/// work to PrayerSchedulerService.
class PrayerBloc extends HydratedBloc<PrayerEvent, PrayerState> {
  final LogPrayerUseCase logPrayerUseCase;
  final GetDailyStatusUseCase getDailyStatusUseCase;
  final OfflineSyncService offlineSyncService;
  final PrayerSchedulerService prayerSchedulerService;

  PrayerBloc({
    required this.logPrayerUseCase,
    required this.getDailyStatusUseCase,
    required this.offlineSyncService,
    required this.prayerSchedulerService,
  }) : super(PrayerState(prayers: Prayer.defaultPrayers())) {
    on<LoadDailyStatus>(_onLoadDailyStatus);
    on<LogPrayer>(_onLogPrayer, transformer: droppable());
    on<ToggleJamaat>(_onToggleJamaat);
    on<SetPrayerLocation>(_onSetPrayerLocation);
    on<SyncWithServer>(_onSyncWithServer);
    on<UpdateCalculationSettings>(_onUpdateCalculationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
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

    // 1. Single GPS call → calculate times + schedule notifications
    final result = await prayerSchedulerService.refreshPrayersAndAlarms(
      currentPrayers: state.prayers,
      state: state,
    );
    if (result != null) {
      emit(state.copyWith(
        prayers: result.prayers,
        cachedLat: result.lat,
        cachedLng: result.lng,
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
      emit(state.copyWith(prayers: merged));
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

    // 3. Update weekly history
    final updatedHistory = Map<String, int>.from(state.weeklyHistory);
    updatedHistory[PrayerState.todayKey] = completedCount;

    emit(state.copyWith(
      prayers: updatedPrayers,
      streak: updatedStreak,
      weeklyHistory: updatedHistory,
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

  /// When user changes calculation method or madhab in settings.
  Future<void> _onUpdateCalculationSettings(
    UpdateCalculationSettings event,
    Emitter<PrayerState> emit,
  ) async {
    final newMethod = event.calculationMethod ?? state.calculationMethod;
    final newHanafi = event.useHanafi ?? state.useHanafi;

    emit(state.copyWith(
      calculationMethod: newMethod,
      useHanafi: newHanafi,
      isLoading: true,
    ));

    // Recalculate with new settings, using cached coords
    final result = await prayerSchedulerService.refreshPrayersAndAlarms(
      currentPrayers: state.prayers,
      state: state,
      methodOverride: newMethod,
      hanafiOverride: newHanafi,
    );
    if (result != null) {
      emit(state.copyWith(
        prayers: result.prayers,
        cachedLat: result.lat,
        cachedLng: result.lng,
        isLoading: false,
      ));
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<PrayerState> emit,
  ) async {
    // NOTE: Permission request has been moved to the UI layer (settings page).
    // The bloc assumes permissions are already granted when this event fires.
    final newState = state.copyWith(
      adhanAlerts: event.adhanAlerts ?? state.adhanAlerts,
      reminderAlerts: event.reminderAlerts ?? state.reminderAlerts,
      reminderMinutes: event.reminderMinutes ?? state.reminderMinutes,
      reminderIsBefore: event.reminderIsBefore ?? state.reminderIsBefore,
      streakProtection: event.streakProtection ?? state.streakProtection,
    );
    emit(newState);

    // Reschedule (or cancel if both off)
    try {
      await prayerSchedulerService.scheduleNotifications(newState);
    } catch (e) {
      debugPrint('[PrayerBloc] Notification reschedule error: $e');
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
