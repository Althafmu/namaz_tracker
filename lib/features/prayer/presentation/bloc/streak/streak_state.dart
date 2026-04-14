import 'package:equatable/equatable.dart';
import '../../../domain/entities/streak.dart';

/// Sync status for offline/online state tracking.
enum SyncStatus { idle, syncing, synced, error }

/// State for the StreakBloc — manages prayer streak data.
/// Separated from PrayerBloc to reduce complexity and improve testability.
class StreakState extends Equatable {
  /// Current streak data (current, longest, display streak)
  final Streak streak;

  /// Loading state for initial data fetch
  final bool isLoading;

  /// Sync status for offline/online state
  final SyncStatus syncStatus;

  const StreakState({
    this.streak = const Streak(),
    this.isLoading = false,
    this.syncStatus = SyncStatus.idle,
  });

  StreakState copyWith({
    Streak? streak,
    bool? isLoading,
    SyncStatus? syncStatus,
  }) {
    return StreakState(
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// JSON serialization for HydratedBloc.
  Map<String, dynamic> toJson() {
    return {
      'streak': streak.toJson(),
    };
  }

  factory StreakState.fromJson(Map<String, dynamic> json) {
    return StreakState(
      streak: json['streak'] != null
          ? Streak.fromJson(json['streak'] as Map<String, dynamic>)
          : const Streak(),
    );
  }

  @override
  List<Object?> get props => [streak, isLoading, syncStatus];
}