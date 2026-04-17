import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../../domain/entities/prayer_notification_config.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  final NotificationService notificationService;
  final AuthRepository? authRepository;

  SettingsBloc({
    required this.notificationService,
    this.authRepository,
  }) : super(const SettingsState()) {
    on<UpdateCalculationSettings>(_onUpdateCalculationSettings);
    on<UpdatePrayerNotificationConfig>(_onUpdatePrayerNotificationConfig);
    on<UpdateGlobalNotificationSettings>(_onUpdateGlobalNotificationSettings);
    on<RequestNotificationPermissions>(_onRequestNotificationPermissions);
    on<UpdateManualOffsets>(_onUpdateManualOffsets);
    on<UpdateMissedReasons>(_onUpdateMissedReasons);
    on<CycleThemeMode>(_onCycleThemeMode);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateAlarmDuration>(_onUpdateAlarmDuration);
    on<SyncSettingsToCloud>(_onSyncSettingsToCloud);
    on<LoadSettingsFromCloud>(_onLoadSettingsFromCloud);
    on<AddExcusedDay>(_onAddExcusedDay);
    on<ClearExcusedDay>(_onClearExcusedDay);
    on<UpdateIntentLevel>(_onUpdateIntentLevel);
    on<LoadIntentFromBackend>(_onLoadIntentFromBackend);
    on<UpdateStreakHistory>(_onUpdateStreakHistory);
    on<MarkMilestoneShown>(_onMarkMilestoneShown);
    on<DismissUpgradePrompt>(_onDismissUpgradePrompt);
  }

  void _onUpdateCalculationSettings(
    UpdateCalculationSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      calculationMethod: event.calculationMethod ?? state.calculationMethod,
      useHanafi: event.useHanafi ?? state.useHanafi,
      methodAutoDetected: true,
    ));
    add(const SyncSettingsToCloud());
  }

  Future<void> _onUpdatePrayerNotificationConfig(
    UpdatePrayerNotificationConfig event,
    Emitter<SettingsState> emit,
  ) async {
    final newConfigs = Map<String, PrayerNotificationConfig>.from(state.prayerConfigs);
    newConfigs[event.prayerName] = event.config;

    final isEnablingAlerts = event.config.adhanAlerts || event.config.reminderAlerts || event.config.streakProtection;

    if (isEnablingAlerts && !state.notificationsPermitted) {
      final granted = await notificationService.requestPermissions();
      emit(state.copyWith(notificationsPermitted: granted));
      if (!granted) {
        debugPrint('[SettingsBloc] Notification permissions denied - aborting alert enablement');
        return;
      }
    }

    emit(state.copyWith(prayerConfigs: newConfigs));
  }

  void _onUpdateGlobalNotificationSettings(
    UpdateGlobalNotificationSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(
      alarmSound: event.alarmSound ?? state.alarmSound,
      notificationsPermitted: event.notificationsPermitted ?? state.notificationsPermitted,
    ));
  }

  Future<void> _onRequestNotificationPermissions(
    RequestNotificationPermissions event,
    Emitter<SettingsState> emit,
  ) async {
    final granted = await notificationService.requestPermissions();
    emit(state.copyWith(notificationsPermitted: granted));
  }

  void _onUpdateManualOffsets(
    UpdateManualOffsets event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(manualOffsets: event.manualOffsets));
    // Kick off cloud sync without blocking the UI
    add(const SyncSettingsToCloud());
  }

  void _onUpdateMissedReasons(
    UpdateMissedReasons event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(missedReasons: event.missedReasons));
  }

  void _onCycleThemeMode(
    CycleThemeMode event,
    Emitter<SettingsState> emit,
  ) {
    String nextMode;
    if (state.themeMode == 'system') {
      nextMode = 'light';
    } else if (state.themeMode == 'light') {
      nextMode = 'dark';
    } else {
      nextMode = 'system';
    }
    
    emit(state.copyWith(themeMode: nextMode));
  }

  void _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onUpdateAlarmDuration(
    UpdateAlarmDuration event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(alarmDurationMinutes: event.duration));
  }

  Future<void> _onSyncSettingsToCloud(
    SyncSettingsToCloud event,
    Emitter<SettingsState> emit,
  ) async {
    if (authRepository == null) return;
    try {
      await authRepository!.updateSettings(
        manualOffsets: state.manualOffsets,
        calculationMethod: state.calculationMethod,
        useHanafi: state.useHanafi,
        intentLevel: state.intentLevel.name,
      );
    } catch (e) {
      debugPrint('[SettingsBloc] Cloud sync failed: $e');
    }
  }

  Future<void> _onLoadSettingsFromCloud(
    LoadSettingsFromCloud event,
    Emitter<SettingsState> emit,
  ) async {
    // HydratedBloc restores state automatically; this handler is for
    // post-login cloud load if needed in the future.
  }

  void _onAddExcusedDay(
    AddExcusedDay event,
    Emitter<SettingsState> emit,
  ) {
    final newExcused = Set<String>.from(state.excusedDays)..add(event.date);
    emit(state.copyWith(excusedDays: newExcused));
  }

  void _onClearExcusedDay(
    ClearExcusedDay event,
    Emitter<SettingsState> emit,
  ) {
    final newExcused = Set<String>.from(state.excusedDays)..remove(event.date);
    emit(state.copyWith(excusedDays: newExcused));
  }

  void _onUpdateIntentLevel(
    UpdateIntentLevel event,
    Emitter<SettingsState> emit,
  ) {
    final intent = IntentLevel.fromString(event.intentLevel);
    emit(state.copyWith(intentLevel: intent, isIntentSet: true));
    add(const SyncSettingsToCloud());
  }

  void _onLoadIntentFromBackend(
    LoadIntentFromBackend event,
    Emitter<SettingsState> emit,
  ) {
    final intent = IntentLevel.fromString(event.intentLevel);
    emit(state.copyWith(
      intentLevel: intent,
      isIntentSet: true,
      isFallbackIntent: event.isFallback,
    ));
  }

  void _onUpdateStreakHistory(
    UpdateStreakHistory event,
    Emitter<SettingsState> emit,
  ) {
    int newBest = state.bestStreak;
    int newLast = state.lastStreak;

    if (event.currentStreak > state.bestStreak) {
      newBest = event.currentStreak;
    }

    if (event.currentStreak == 0 && state.lastStreak > 0) {
      newLast = state.lastStreak;
    } else if (event.currentStreak > 0) {
      newLast = event.currentStreak;
    }

    emit(state.copyWith(
      bestStreak: newBest,
      lastStreak: newLast,
    ));
  }

  void _onMarkMilestoneShown(
    MarkMilestoneShown event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(milestones: state.milestones.markShown(event.milestone)));
  }

  void _onDismissUpgradePrompt(
    DismissUpgradePrompt event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(upgradePrompt: state.upgradePrompt.markDismissed()));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    try {
      return SettingsState.fromJson(json);
    } catch (e) {
      debugPrint('[SettingsBloc] Error fromJson: $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    try {
      return state.toJson();
    } catch (e) {
      debugPrint('[SettingsBloc] Error toJson: $e');
      return null;
    }
  }
}
