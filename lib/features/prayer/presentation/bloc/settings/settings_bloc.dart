import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../../domain/entities/prayer_notification_config.dart';
import '../../../domain/usecases/pause_notifications_for_today_usecase.dart';
import '../../../domain/usecases/get_notifications_pause_status_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  final NotificationService notificationService;
  final AuthRepository? authRepository;
  final PauseNotificationsForTodayUseCase? pauseNotificationsForTodayUseCase;
  final GetNotificationsPauseStatusUseCase? getNotificationsPauseStatusUseCase;

  SettingsBloc({
    required this.notificationService,
    this.authRepository,
    this.pauseNotificationsForTodayUseCase,
    this.getNotificationsPauseStatusUseCase,
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
    on<UpdateSunnahEnabled>(_onUpdateSunnahEnabled);
    on<LoadSunnahEnabledFromBackend>(_onLoadSunnahEnabledFromBackend);
    on<UpdateQadaTrackingEnabled>(_onUpdateQadaTrackingEnabled);
    on<UpdateStreakHistory>(_onUpdateStreakHistory);
    on<MarkMilestoneShown>(_onMarkMilestoneShown);
    on<DismissUpgradePrompt>(_onDismissUpgradePrompt);
    on<MarkHomeWelcomeSeen>(_onMarkHomeWelcomeSeen);
    on<CompleteFirstRunSetup>(_onCompleteFirstRunSetup);
    on<PauseNotificationsForToday>(_onPauseNotificationsForToday);
    on<LoadNotificationsPauseStatus>(_onLoadNotificationsPauseStatus);
    on<ResetSessionScopedSettings>(_onResetSessionScopedSettings);
    on<MarkLoginNotificationPromptSeen>(_onMarkLoginNotificationPromptSeen);
  }

  void _emitInitialized(Emitter<SettingsState> emit, SettingsState nextState) {
    emit(nextState.copyWith(isInitialized: true));
  }

  void _onUpdateCalculationSettings(
    UpdateCalculationSettings event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(
      emit,
      state.copyWith(
        calculationMethod: event.calculationMethod ?? state.calculationMethod,
        useHanafi: event.useHanafi ?? state.useHanafi,
        methodAutoDetected:
            event.methodAutoDetected ?? state.methodAutoDetected,
      ),
    );
    add(const SyncSettingsToCloud());
  }

  Future<void> _onUpdatePrayerNotificationConfig(
    UpdatePrayerNotificationConfig event,
    Emitter<SettingsState> emit,
  ) async {
    final newConfigs = Map<String, PrayerNotificationConfig>.from(
      state.prayerConfigs,
    );
    newConfigs[event.prayerName] = event.config;

    final isEnablingAlerts =
        event.config.adhanAlerts ||
        event.config.reminderAlerts ||
        event.config.streakProtection;

    if (isEnablingAlerts && !state.notificationsPermitted) {
      final granted = await notificationService.requestPermissions();
      _emitInitialized(emit, state.copyWith(notificationsPermitted: granted));
      if (!granted) {
        debugPrint(
          '[SettingsBloc] Notification permissions denied - aborting alert enablement',
        );
        return;
      }
    }

    _emitInitialized(emit, state.copyWith(prayerConfigs: newConfigs));
  }

  void _onUpdateGlobalNotificationSettings(
    UpdateGlobalNotificationSettings event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(
      emit,
      state.copyWith(
        alarmSound: event.alarmSound ?? state.alarmSound,
        notificationsPermitted:
            event.notificationsPermitted ?? state.notificationsPermitted,
      ),
    );
  }

  Future<void> _onRequestNotificationPermissions(
    RequestNotificationPermissions event,
    Emitter<SettingsState> emit,
  ) async {
    final granted = await notificationService.requestPermissions();
    _emitInitialized(emit, state.copyWith(notificationsPermitted: granted));
  }

  void _onUpdateManualOffsets(
    UpdateManualOffsets event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(emit, state.copyWith(manualOffsets: event.manualOffsets));
    // Kick off cloud sync without blocking the UI
    add(const SyncSettingsToCloud());
  }

  void _onUpdateMissedReasons(
    UpdateMissedReasons event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(emit, state.copyWith(missedReasons: event.missedReasons));
  }

  void _onCycleThemeMode(CycleThemeMode event, Emitter<SettingsState> emit) {
    String nextMode;
    if (state.themeMode == 'system') {
      nextMode = 'light';
    } else if (state.themeMode == 'light') {
      nextMode = 'dark';
    } else {
      nextMode = 'system';
    }

    _emitInitialized(emit, state.copyWith(themeMode: nextMode));
  }

  void _onUpdateThemeMode(UpdateThemeMode event, Emitter<SettingsState> emit) {
    _emitInitialized(emit, state.copyWith(themeMode: event.themeMode));
  }

  void _onUpdateAlarmDuration(
    UpdateAlarmDuration event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(
      emit,
      state.copyWith(alarmDurationMinutes: event.duration),
    );
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
        sunnahEnabled: state.sunnahEnabled,
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

  void _onAddExcusedDay(AddExcusedDay event, Emitter<SettingsState> emit) {
    final newExcused = Set<String>.from(state.excusedDays)..add(event.date);
    _emitInitialized(emit, state.copyWith(excusedDays: newExcused));
  }

  void _onClearExcusedDay(ClearExcusedDay event, Emitter<SettingsState> emit) {
    final newExcused = Set<String>.from(state.excusedDays)..remove(event.date);
    _emitInitialized(emit, state.copyWith(excusedDays: newExcused));
  }

  void _onUpdateIntentLevel(
    UpdateIntentLevel event,
    Emitter<SettingsState> emit,
  ) {
    final intent = IntentLevel.fromString(event.intentLevel);
    _emitInitialized(
      emit,
      state.copyWith(
        intentLevel: intent,
        isIntentSet: true,
        isFallbackIntent: false,
        sunnahEnabled: intent == IntentLevel.growth
            ? state.sunnahEnabled
            : false,
      ),
    );
    add(const SyncSettingsToCloud());
  }

  void _onLoadIntentFromBackend(
    LoadIntentFromBackend event,
    Emitter<SettingsState> emit,
  ) {
    final intent = IntentLevel.fromString(event.intentLevel);
    _emitInitialized(
      emit,
      state.copyWith(
        intentLevel: intent,
        isIntentSet: !event.isFallback,
        isFallbackIntent: event.isFallback,
        sunnahEnabled: intent == IntentLevel.growth
            ? state.sunnahEnabled
            : false,
      ),
    );
  }

  void _onUpdateSunnahEnabled(
    UpdateSunnahEnabled event,
    Emitter<SettingsState> emit,
  ) {
    final isGrowth = state.intentLevel == IntentLevel.growth;
    final nextValue = isGrowth ? event.enabled : false;
    _emitInitialized(emit, state.copyWith(sunnahEnabled: nextValue));
    add(const SyncSettingsToCloud());
  }

  void _onLoadSunnahEnabledFromBackend(
    LoadSunnahEnabledFromBackend event,
    Emitter<SettingsState> emit,
  ) {
    final isGrowth = state.intentLevel == IntentLevel.growth;
    _emitInitialized(
      emit,
      state.copyWith(sunnahEnabled: isGrowth ? event.enabled : false),
    );
  }

  void _onUpdateQadaTrackingEnabled(
    UpdateQadaTrackingEnabled event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(emit, state.copyWith(qadaTrackingEnabled: event.enabled));
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

    _emitInitialized(
      emit,
      state.copyWith(bestStreak: newBest, lastStreak: newLast),
    );
  }

  void _onMarkMilestoneShown(
    MarkMilestoneShown event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(
      emit,
      state.copyWith(milestones: state.milestones.markShown(event.milestone)),
    );
  }

  void _onDismissUpgradePrompt(
    DismissUpgradePrompt event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(
      emit,
      state.copyWith(upgradePrompt: state.upgradePrompt.markDismissed()),
    );
  }

  void _onMarkHomeWelcomeSeen(
    MarkHomeWelcomeSeen event,
    Emitter<SettingsState> emit,
  ) {
    if (state.hasSeenHomeWelcomeBanner) return;
    _emitInitialized(emit, state.copyWith(hasSeenHomeWelcomeBanner: true));
  }

  void _onCompleteFirstRunSetup(
    CompleteFirstRunSetup event,
    Emitter<SettingsState> emit,
  ) {
    if (state.hasCompletedFirstRunSetup) return;
    _emitInitialized(emit, state.copyWith(hasCompletedFirstRunSetup: true));
  }

  Future<void> _onPauseNotificationsForToday(
    PauseNotificationsForToday event,
    Emitter<SettingsState> emit,
  ) async {
    if (pauseNotificationsForTodayUseCase == null) {
      _emitInitialized(
        emit,
        state.copyWith(
          pauseActionStatus: PauseActionStatus.error,
          lastSettingsActionMessage: 'Pause notifications is not available.',
        ),
      );
      return;
    }

    _emitInitialized(
      emit,
      state.copyWith(pauseActionStatus: PauseActionStatus.loading),
    );

    try {
      await pauseNotificationsForTodayUseCase!();
      _emitInitialized(
        emit,
        state.copyWith(
          notificationsPausedToday: true,
          pauseActionStatus: PauseActionStatus.success,
          lastSettingsActionMessage: 'Notifications paused for today.',
        ),
      );
    } on ServerException catch (e) {
      _emitInitialized(
        emit,
        state.copyWith(
          pauseActionStatus: PauseActionStatus.error,
          lastSettingsActionMessage: e.userMessage,
        ),
      );
    } on NetworkException catch (e) {
      _emitInitialized(
        emit,
        state.copyWith(
          pauseActionStatus: PauseActionStatus.error,
          lastSettingsActionMessage:
              'Network error. Please check your connection.',
        ),
      );
      debugPrint(
        '[SettingsBloc] Network error pausing notifications: ${e.message}',
      );
    } catch (e) {
      _emitInitialized(
        emit,
        state.copyWith(
          pauseActionStatus: PauseActionStatus.error,
          lastSettingsActionMessage: 'Failed to pause notifications.',
        ),
      );
      debugPrint('[SettingsBloc] Unexpected error pausing notifications: $e');
    }
  }

  Future<void> _onLoadNotificationsPauseStatus(
    LoadNotificationsPauseStatus event,
    Emitter<SettingsState> emit,
  ) async {
    if (getNotificationsPauseStatusUseCase == null) return;

    try {
      final result = await getNotificationsPauseStatusUseCase!();
      final isPaused = result['is_paused'] as bool? ?? false;
      _emitInitialized(
        emit,
        state.copyWith(notificationsPausedToday: isPaused),
      );
    } catch (e) {
      debugPrint('[SettingsBloc] Error loading pause status: $e');
    }
  }

  void _onResetSessionScopedSettings(
    ResetSessionScopedSettings event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(
      emit,
      state.copyWith(
        intentLevel: IntentLevel.foundation,
        isIntentSet: false,
        isFallbackIntent: false,
        sunnahEnabled: false,
        notificationsPausedToday: false,
        pauseActionStatus: PauseActionStatus.idle,
        excusedDays: <String>{},
        hasSeenLoginNotificationPrompt: false,
        clearActionMessage: true,
      ),
    );
  }

  void _onMarkLoginNotificationPromptSeen(
    MarkLoginNotificationPromptSeen event,
    Emitter<SettingsState> emit,
  ) {
    _emitInitialized(
      emit,
      state.copyWith(hasSeenLoginNotificationPrompt: true),
    );
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
