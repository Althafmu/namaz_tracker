import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer.dart';

/// Base event for StreakBloc.
abstract class StreakEvent extends Equatable {
  const StreakEvent();

  @override
  List<Object?> get props => [];
}

/// Load streak from server.
class LoadStreak extends StreakEvent {
  const LoadStreak();
}

/// Update streak values directly (from server response).
class UpdateStreak extends StreakEvent {
  final int currentStreak;
  final int longestStreak;
  final int displayStreak;

  const UpdateStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.displayStreak,
  });

  @override
  List<Object?> get props => [currentStreak, longestStreak, displayStreak];
}

/// Recalculate streak from historical prayer data.
/// Dispatched when HistoryBloc state changes.
class RecalculateStreakFromHistory extends StreakEvent {
  /// Map of date string -> list of prayers for that day
  final Map<String, List<Prayer>> historicalLog;

  const RecalculateStreakFromHistory(this.historicalLog);

  @override
  List<Object?> get props => [historicalLog];
}

// ── Phase 2: Streak Freeze System ──

/// Consume a protector token to save streak after Qada prayer.
class ConsumeProtectorToken extends StreakEvent {
  /// Optional date for the token consumption (defaults to yesterday).
  final String? date;

  const ConsumeProtectorToken({this.date});

  @override
  List<Object?> get props => [date];
}

/// Mark a day as excused (travel, sickness, women's period).
class SetExcusedDay extends StreakEvent {
  /// The date to mark as excused (required).
  final String date;
  /// Optional reason (travel, sickness, period, etc.).
  final String? reason;

  const SetExcusedDay({
    required this.date,
    this.reason,
  });

  @override
  List<Object?> get props => [date, reason];
}