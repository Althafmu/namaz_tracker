import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../domain/entities/prayer_notification_config.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  final NotificationService notificationService;

  SettingsBloc({
    required this.notificationService,
  }) : super(const SettingsState()) {
    on<UpdateCalculationSettings>(_onUpdateCalculationSettings);
    on<UpdatePrayerNotificationConfig>(_onUpdatePrayerNotificationConfig);
    on<UpdateGlobalNotificationSettings>(_onUpdateGlobalNotificationSettings);
    on<RequestNotificationPermissions>(_onRequestNotificationPermissions);
    on<UpdateManualOffsets>(_onUpdateManualOffsets);
    on<UpdateMissedReasons>(_onUpdateMissedReasons);
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
  }

  void _onUpdateMissedReasons(
    UpdateMissedReasons event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(missedReasons: event.missedReasons));
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
