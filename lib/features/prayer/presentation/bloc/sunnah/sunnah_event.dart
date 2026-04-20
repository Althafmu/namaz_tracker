import 'package:equatable/equatable.dart';

abstract class SunnahEvent extends Equatable {
  const SunnahEvent();

  @override
  List<Object?> get props => [];
}

/// Load the daily sunnah summary for a specific date.
/// Returns cached data immediately, then refreshes from remote.
class LoadDailySunnah extends SunnahEvent {
  final String dateKey;
  const LoadDailySunnah(this.dateKey);

  @override
  List<Object?> get props => [dateKey];
}

/// Toggle a sunnah prayer type (optimistic local + remote sync).
class ToggleSunnahPrayer extends SunnahEvent {
  final String prayerType;
  final String dateKey;
  const ToggleSunnahPrayer({required this.prayerType, required this.dateKey});

  @override
  List<Object?> get props => [prayerType, dateKey];
}

/// Explicitly set a sunnah prayer completion state.
class SetSunnahPrayerCompletion extends SunnahEvent {
  final String prayerType;
  final String dateKey;
  final bool completed;

  const SetSunnahPrayerCompletion({
    required this.prayerType,
    required this.dateKey,
    required this.completed,
  });

  @override
  List<Object?> get props => [prayerType, dateKey, completed];
}

/// Load the weekly sunnah summary starting from a given date.
class LoadWeeklySunnah extends SunnahEvent {
  final String? startDateKey;
  const LoadWeeklySunnah({this.startDateKey});

  @override
  List<Object?> get props => [startDateKey];
}
