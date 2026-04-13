import '../../domain/entities/streak.dart';

/// Data model extending the Streak entity with server-side JSON mapping.
class StreakModel extends Streak {
  const StreakModel({
    super.currentStreak,
    super.longestStreak,
    super.lastCompletedDate,
    super.displayStreak,
  });

  factory StreakModel.fromApiResponse(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastCompletedDate: json['last_completed_date'] as String?,
      displayStreak: json['display_streak'] as int? ?? 0,
    );
  }
}
