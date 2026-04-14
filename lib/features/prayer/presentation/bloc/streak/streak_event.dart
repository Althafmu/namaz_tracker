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