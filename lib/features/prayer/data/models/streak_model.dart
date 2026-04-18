import '../../domain/entities/streak.dart';

/// Data model extending the Streak entity with server-side JSON mapping.
/// Sprint 1 (Phase 3 PRD): Includes weekly token limits + anti-gaming cooldown.
///
/// Null/missing-field safeguards: all numeric fields default to safe values,
/// all optional strings default to null. Unexpected types are coerced to int.
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

  /// Safely parse a numeric value that may come as int, double, or null.
  static int _safeInt(dynamic value, int defaultValue) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory StreakModel.fromApiResponse(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: _safeInt(json['current_streak'], 0),
      longestStreak: _safeInt(json['longest_streak'], 0),
      lastCompletedDate: json['last_completed_date'] as String?,
      displayStreak: _safeInt(json['display_streak'], 0),
      protectorTokens: _safeInt(json['protector_tokens'], 3),
      maxProtectorTokens: _safeInt(json['max_protector_tokens'], 3),
      tokensResetDate: json['tokens_reset_date'] as String?,
      weeklyTokensUsed: _safeInt(json['weekly_tokens_used'], 0),
      weeklyTokenLimit: _safeInt(json['weekly_token_limit'], 3),
      weeklyTokensRemaining: _safeInt(json['weekly_tokens_remaining'], 3),
      lastTokenUsedAt: json['last_token_used_at'] as String?,
      antiGamingCooldownHours: _safeInt(json['anti_gaming_cooldown_hours'], 24),
    );
  }

  Map<String, dynamic> toUpdateRequest() {
    return {
      'protector_tokens': protectorTokens,
      'tokens_reset_date': tokensResetDate,
    };
  }
}
