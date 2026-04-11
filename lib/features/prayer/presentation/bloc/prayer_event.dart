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
  final String status;
  final String? reason;

  const LogPrayer({
    required this.prayerName,
    required this.completed,
    this.inJamaat = false,
    this.location = 'home',
    this.status = 'on_time',
    this.reason,
  });

  @override
  List<Object?> get props => [prayerName, completed, inJamaat, location, status, reason];
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

/// Refresh prayers and alarms when settings change.
class RefreshPrayersAndAlarms extends PrayerEvent {
  const RefreshPrayersAndAlarms();
}

/// Load detailed prayer history for a specific month (calendar navigation).
class LoadMonthHistory extends PrayerEvent {
  final int year;
  final int month;

  const LoadMonthHistory({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

/// Load aggregated reason counts from backend (all-time).
class LoadAllReasons extends PrayerEvent {
  const LoadAllReasons();
}
