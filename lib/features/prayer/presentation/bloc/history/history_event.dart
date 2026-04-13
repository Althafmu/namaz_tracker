import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer.dart';

/// Base event for HistoryBloc.
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load detailed prayer history for a specific month.
class LoadMonthHistory extends HistoryEvent {
  final int year;
  final int month;

  const LoadMonthHistory({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

/// Select a date for viewing/editing past logs.
class SelectDate extends HistoryEvent {
  final String dateStr;

  const SelectDate(this.dateStr);

  @override
  List<Object?> get props => [dateStr];
}

/// Clear the selected date (return to today).
class ClearSelectedDate extends HistoryEvent {
  const ClearSelectedDate();
}

/// Update a specific day's prayer log (called by PrayerBloc after logging).
class UpdateDayLog extends HistoryEvent {
  final String dateStr;
  final List<Prayer> prayers;

  const UpdateDayLog({required this.dateStr, required this.prayers});

  @override
  List<Object?> get props => [dateStr, prayers];
}

/// Merge server data into historical log (called during sync).
class MergeMonthData extends HistoryEvent {
  final Map<String, List<Prayer>> monthData;
  final bool preserveToday;

  const MergeMonthData({required this.monthData, this.preserveToday = true});

  @override
  List<Object?> get props => [monthData, preserveToday];
}

/// Clear all historical data (for logout or data reset).
class ClearHistory extends HistoryEvent {
  const ClearHistory();
}