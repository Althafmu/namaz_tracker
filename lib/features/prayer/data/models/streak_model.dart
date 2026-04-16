import '../../domain/entities/streak.dart';

/// Data model extending the Streak entity with server-side JSON mapping.
/// Sprint 1 (Phase 3 PRD): Includes weekly token limits + anti-gaming cooldown.
class StreakModel extends Streak {
  const StreakModel({
    super.currentStreak,
    super.longestStreak,
    super.lastCompletedDate,
    super.displayStreak,
    super.protectorTokens,
    super.maxProtectorTokens,
    super.tokensResetDate,
    super.weeklyTokensUsed,
    super.weeklyTokenLimit,
    super.weeklyTokensRemaining,
    super.lastTokenUsedAt,
    super.antiGamingCooldownHours,
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
      weeklyTokensUsed: json['weekly_tokens_used'] as int? ?? 0,
      weeklyTokenLimit: json['weekly_token_limit'] as int? ?? 3,
      weeklyTokensRemaining: json['weekly_tokens_remaining'] as int? ?? 3,
      lastTokenUsedAt: json['last_token_used_at'] as String?,
      antiGamingCooldownHours: json['anti_gaming_cooldown_hours'] as int? ?? 24,
    );
  }

  Map<String, dynamic> toUpdateRequest() {
    return {
      'protector_tokens': protectorTokens,
      'tokens_reset_date': tokensResetDate,
    };
  }
}
