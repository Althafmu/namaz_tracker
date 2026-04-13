import 'package:equatable/equatable.dart';

/// Base event for StatsBloc.
abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Load aggregated reason counts from backend.
class LoadAllReasons extends StatsEvent {
  const LoadAllReasons();
}

/// Update reason count (called by PrayerBloc after logging a late/missed prayer).
class UpdateReason extends StatsEvent {
  final String reason;
  final int delta;

  const UpdateReason({required this.reason, required this.delta});

  @override
  List<Object?> get props => [reason, delta];
}

/// Clear all statistics (for logout or data reset).
class ClearStats extends StatsEvent {
  const ClearStats();
}