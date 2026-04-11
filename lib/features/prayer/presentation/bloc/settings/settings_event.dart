import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer_notification_config.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateCalculationSettings extends SettingsEvent {
  final String? calculationMethod;
  final bool? useHanafi;
  final bool? methodAutoDetected;

  const UpdateCalculationSettings({
    this.calculationMethod,
    this.useHanafi,
    this.methodAutoDetected,
  });

  @override
  List<Object?> get props => [calculationMethod, useHanafi, methodAutoDetected];
}

class UpdatePrayerNotificationConfig extends SettingsEvent {
  final String prayerName;
  final PrayerNotificationConfig config;

  const UpdatePrayerNotificationConfig({
    required this.prayerName,
    required this.config,
  });

  @override
  List<Object?> get props => [prayerName, config];
}

class UpdateGlobalNotificationSettings extends SettingsEvent {
  final String? alarmSound;
  final bool? notificationsPermitted;

  const UpdateGlobalNotificationSettings({
    this.alarmSound,
    this.notificationsPermitted,
  });

  @override
  List<Object?> get props => [alarmSound, notificationsPermitted];
}

class UpdateManualOffsets extends SettingsEvent {
  final Map<String, int> manualOffsets;

  const UpdateManualOffsets({
    required this.manualOffsets,
  });

  @override
  List<Object?> get props => [manualOffsets];
}

class RequestNotificationPermissions extends SettingsEvent {}
