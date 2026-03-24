import 'package:equatable/equatable.dart';

/// Events for the PrayerBloc.
abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's prayer status (fires on app launch).
class LoadDailyStatus extends PrayerEvent {
  const LoadDailyStatus();
}

/// Log a single prayer as completed/uncompleted.
class LogPrayer extends PrayerEvent {
  final String prayerName;
  final bool completed;
  final bool inJamaat;
  final String location;

  const LogPrayer({
    required this.prayerName,
    required this.completed,
    this.inJamaat = false,
    this.location = 'home',
  });

  @override
  List<Object?> get props => [prayerName, completed, inJamaat, location];
}

/// Toggle jama'at for the prayer logger.
class ToggleJamaat extends PrayerEvent {
  final String prayerName;

  const ToggleJamaat({required this.prayerName});

  @override
  List<Object?> get props => [prayerName];
}

/// Set the selected location for the prayer logger.
class SetPrayerLocation extends PrayerEvent {
  final String location;

  const SetPrayerLocation({required this.location});

  @override
  List<Object?> get props => [location];
}

/// Sync local state with the backend.
class SyncWithServer extends PrayerEvent {
  const SyncWithServer();
}

/// Update calculation method and/or madhab, then recalculate times.
class UpdateCalculationSettings extends PrayerEvent {
  final String? calculationMethod;
  final bool? useHanafi;

  const UpdateCalculationSettings({this.calculationMethod, this.useHanafi});

  @override
  List<Object?> get props => [calculationMethod, useHanafi];
}

/// Update local OS notification settings and reschedule alarms.
class UpdateNotificationSettings extends PrayerEvent {
  final bool? adhanAlerts;
  final bool? reminderAlerts;
  final int? reminderMinutes;
  final bool? reminderIsBefore;
  final bool? streakProtection;

  const UpdateNotificationSettings({
    this.adhanAlerts,
    this.reminderAlerts,
    this.reminderMinutes,
    this.reminderIsBefore,
    this.streakProtection,
  });

  @override
  List<Object?> get props => [
        adhanAlerts,
        reminderAlerts,
        reminderMinutes,
        reminderIsBefore,
        streakProtection,
      ];
}
