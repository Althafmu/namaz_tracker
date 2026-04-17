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

class UpdateMissedReasons extends SettingsEvent {
  final List<String> missedReasons;

  const UpdateMissedReasons({
    required this.missedReasons,
  });

  @override
  List<Object?> get props => [missedReasons];
}

class CycleThemeMode extends SettingsEvent {
  const CycleThemeMode();
}

class UpdateThemeMode extends SettingsEvent {
  final String themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateAlarmDuration extends SettingsEvent {
  final int duration;

  const UpdateAlarmDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Syncs manual offsets, calculation method, and hanafi setting to cloud.
class SyncSettingsToCloud extends SettingsEvent {
  const SyncSettingsToCloud();
}

/// Loads settings from cloud on app startup / login.
class LoadSettingsFromCloud extends SettingsEvent {
  const LoadSettingsFromCloud();
}

/// Marks a date as excused — suppresses all notifications for that day.
class AddExcusedDay extends SettingsEvent {
  final String date; // yyyy-MM-dd

  const AddExcusedDay(this.date);

  @override
  List<Object?> get props => [date];
}

/// Removes a date from the excused list — re-enables notifications.
class ClearExcusedDay extends SettingsEvent {
  final String date; // yyyy-MM-dd

  const ClearExcusedDay(this.date);

  @override
  List<Object?> get props => [date];
}

/// Phase 3.1: Intent level selection
class UpdateIntentLevel extends SettingsEvent {
  final String intentLevel;

  const UpdateIntentLevel(this.intentLevel);

  @override
  List<Object?> get props => [intentLevel];
}

class LoadIntentFromBackend extends SettingsEvent {
  final String intentLevel;

  const LoadIntentFromBackend(this.intentLevel);

  @override
  List<Object?> get props => [intentLevel];
}

/// Phase 3.1: Track streak history for soft landing and upgrade prompts
class UpdateStreakHistory extends SettingsEvent {
  final int currentStreak;

  const UpdateStreakHistory(this.currentStreak);

  @override
  List<Object?> get props => [currentStreak];
}

/// Phase 3.1: Mark a milestone as shown
class MarkMilestoneShown extends SettingsEvent {
  final int milestone;

  const MarkMilestoneShown(this.milestone);

  @override
  List<Object?> get props => [milestone];
}

/// Phase 3.1: Dismiss upgrade prompt
class DismissUpgradePrompt extends SettingsEvent {
  const DismissUpgradePrompt();
}
