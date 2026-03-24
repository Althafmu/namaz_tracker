import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/services/prayer_time_service.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/usecases/log_prayer_usecase.dart';
import '../../domain/usecases/get_daily_status_usecase.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

/// PrayerBloc — HydratedBloc for offline persistence + bloc_concurrency.
///
/// - On launch, fetches GPS location and calculates real prayer times via adhan.
/// - LogPrayer uses droppable() to prevent duplicate requests on double-tap.
/// - Optimistically updates the local streak.
/// - Persists calculation method + madhab preference across sessions.
class PrayerBloc extends HydratedBloc<PrayerEvent, PrayerState> {
  final LogPrayerUseCase logPrayerUseCase;
  final GetDailyStatusUseCase getDailyStatusUseCase;
  final OfflineSyncService offlineSyncService;
  final NotificationService notificationService;

  PrayerBloc({
    required this.logPrayerUseCase,
    required this.getDailyStatusUseCase,
    required this.offlineSyncService,
    required this.notificationService,
  }) : super(PrayerState(prayers: Prayer.defaultPrayers())) {
    on<LoadDailyStatus>(_onLoadDailyStatus);
    on<LogPrayer>(_onLogPrayer, transformer: droppable());
    on<ToggleJamaat>(_onToggleJamaat);
    on<SetPrayerLocation>(_onSetPrayerLocation);
    on<SyncWithServer>(_onSyncWithServer);
    on<UpdateCalculationSettings>(_onUpdateCalculationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
  }

  /// Recalculate prayer time ranges using adhan + GPS location.
  Future<List<Prayer>> _recalculateTimes(List<Prayer> currentPrayers, {
    String? methodOverride,
    bool? hanafiOverride,
  }) async {
    final coords = await PrayerTimeService.getCurrentLocation();
    if (coords == null) return currentPrayers; // No location → keep existing times

    final method = methodOverride ?? state.calculationMethod;
    final hanafi = hanafiOverride ?? state.useHanafi;

    final timeRanges = PrayerTimeService.getPrayerTimeRanges(
      coordinates: coords,
      methodName: method,
      useHanafi: hanafi,
    );

    return currentPrayers.map((prayer) {
      final newRange = timeRanges[prayer.name];
      return newRange != null ? prayer.copyWith(timeRange: newRange) : prayer;
    }).toList();
  }

  /// Reschedule notifications for today. Returns count of scheduled alarms.
  Future<int> _rescheduleNotifications(PrayerState st) async {
    try {
      final coords = await PrayerTimeService.getCurrentLocation();
      if (coords == null) return 0;

      return await notificationService.schedulePrayerNotifications(
        coordinates: coords,
        methodName: st.calculationMethod,
        useHanafi: st.useHanafi,
        adhanAlerts: st.adhanAlerts,
        reminderAlerts: st.reminderAlerts,
        reminderMinutes: st.reminderMinutes,
        reminderIsBefore: st.reminderIsBefore,
      );
    } catch (e) {
      return 0;
    }
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

    // 1. Calculate real prayer times from GPS + adhan
    final prayersWithTimes = await _recalculateTimes(state.prayers);
    emit(state.copyWith(prayers: prayersWithTimes, isLoading: false));

    // Reschedule today's notifications
    try {
      await _rescheduleNotifications(state);
    } catch (_) {}

    // 2. Try to sync completion status with server
    try {
      final serverPrayers = await getDailyStatusUseCase();
      // Merge: keep calculated times, but use server completion status
      final merged = prayersWithTimes.map((local) {
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
      // Offline — keep local hydrated state with calculated times
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

    // 3. Sync with backend
    try {
      await logPrayerUseCase(
        prayerName: event.prayerName,
        completed: event.completed,
        inJamaat: event.inJamaat,
        location: event.location,
      );
      emit(state.copyWith(syncStatus: SyncStatus.synced));
    } catch (e) {
      // API call failed (e.g., offline) -> Save to local sync queue
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

  /// When user changes calculation method or madhab in Profile settings.
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

    // Recalculate prayer times with new settings
    final recalculated = await _recalculateTimes(
      state.prayers,
      methodOverride: newMethod,
      hanafiOverride: newHanafi,
    );

    emit(state.copyWith(prayers: recalculated, isLoading: false));
    
    // Reschedule notifications with new settings
    try {
      await _rescheduleNotifications(state);
    } catch (_) {}
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<PrayerState> emit,
  ) async {
    final newAdhan = event.adhanAlerts ?? state.adhanAlerts;
    final newReminder = event.reminderAlerts ?? state.reminderAlerts;

    // Request permissions if user is enabling alerts for the first time
    final enablingAlerts = (newAdhan && !state.adhanAlerts) ||
        (newReminder && !state.reminderAlerts);
    if (enablingAlerts) {
      await notificationService.requestPermissions();
    }

    final newState = state.copyWith(
      adhanAlerts: newAdhan,
      reminderAlerts: newReminder,
      reminderMinutes: event.reminderMinutes ?? state.reminderMinutes,
      reminderIsBefore: event.reminderIsBefore ?? state.reminderIsBefore,
      streakProtection: event.streakProtection ?? state.streakProtection,
    );
    emit(newState);

    // Reschedule (or cancel if both off)
    try {
      await _rescheduleNotifications(newState);
    } catch (_) {}
  }

  // ── HydratedBloc overrides ──

  @override
  PrayerState? fromJson(Map<String, dynamic> json) {
    try {
      return PrayerState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PrayerState state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }
}
