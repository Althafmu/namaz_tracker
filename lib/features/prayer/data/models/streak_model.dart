import '../../domain/entities/streak.dart';

/// Data model extending the Streak entity with server-side JSON mapping.
/// Phase 2: Includes protector tokens for streak freeze system.
class StreakModel extends Streak {
  const StreakModel({
    super.currentStreak,
    super.longestStreak,
    super.lastCompletedDate,
    super.displayStreak,
    super.protectorTokens,
    super.maxProtectorTokens,
    super.tokensResetDate,
  });

  factory StreakModel.fromApiResponse(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastCompletedDate: json['last_completed_date'] as String?,
      displayStreak: json['display_streak'] as int? ?? 0,
      protectorTokens: json['protector_tokens'] as int? ?? 3,
      maxProtectorTokens: json['max_protector_tokens'] as int? ?? 3,
      tokensResetDate: json['tokens_reset_date'] as String?,
    );
  }

  Map<String, dynamic> toUpdateRequest() {
    return {
      'protector_tokens': protectorTokens,
      'tokens_reset_date': tokensResetDate,
    };
  }
}
