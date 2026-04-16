import 'package:equatable/equatable.dart';

/// Prayer status types for Phase 2 streak engine
enum PrayerStatus {
  onTime,
  late,
  missed,
  qada,
  excused,
  pending,
}

/// Extension for PrayerStatus string conversion
extension PrayerStatusX on PrayerStatus {
  String get value {
    switch (this) {
      case PrayerStatus.onTime:
        return 'on_time';
      case PrayerStatus.late:
        return 'late';
      case PrayerStatus.missed:
        return 'missed';
      case PrayerStatus.qada:
        return 'qada';
      case PrayerStatus.excused:
        return 'excused';
      case PrayerStatus.pending:
        return 'pending';
    }
  }

  static PrayerStatus fromString(String value) {
    switch (value) {
      case 'on_time':
        return PrayerStatus.onTime;
      case 'late':
        return PrayerStatus.late;
      case 'missed':
        return PrayerStatus.missed;
      case 'qada':
        return PrayerStatus.qada;
      case 'excused':
        return PrayerStatus.excused;
      case 'pending':
        return PrayerStatus.pending;
      default:
        return PrayerStatus.pending;
    }
  }
}

/// Represents the user's prayer streak.
/// Sprint 1 (Phase 3 PRD): Includes weekly token limits + anti-gaming cooldown.
class Streak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate;
  final int displayStreak;

  // Phase 2: Streak protection
  final int protectorTokens;
  final int maxProtectorTokens;
  final String? tokensResetDate;

  // Sprint 1: Weekly token tracking + anti-gaming
  final int weeklyTokensUsed;
  final int weeklyTokenLimit;
  final int weeklyTokensRemaining;
  final String? lastTokenUsedAt;  // ISO8601 timestamp
  final int antiGamingCooldownHours;

  const Streak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.displayStreak = 0,
    this.protectorTokens = 3,
    this.maxProtectorTokens = 3,
    this.tokensResetDate,
    this.weeklyTokensUsed = 0,
    this.weeklyTokenLimit = 3,
    this.weeklyTokensRemaining = 3,
    this.lastTokenUsedAt,
    this.antiGamingCooldownHours = 24,
  });

  bool get hasProtectorTokens => protectorTokens > 0;

  /// Sprint 1: Check if weekly recovery limit has been reached.
  bool get weeklyLimitReached => weeklyTokensUsed >= weeklyTokenLimit;

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
    int? displayStreak,
    int? protectorTokens,
    int? maxProtectorTokens,
    String? tokensResetDate,
    int? weeklyTokensUsed,
    int? weeklyTokenLimit,
    int? weeklyTokensRemaining,
    String? lastTokenUsedAt,
    int? antiGamingCooldownHours,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      displayStreak: displayStreak ?? this.displayStreak,
      protectorTokens: protectorTokens ?? this.protectorTokens,
      maxProtectorTokens: maxProtectorTokens ?? this.maxProtectorTokens,
      tokensResetDate: tokensResetDate ?? this.tokensResetDate,
      weeklyTokensUsed: weeklyTokensUsed ?? this.weeklyTokensUsed,
      weeklyTokenLimit: weeklyTokenLimit ?? this.weeklyTokenLimit,
      weeklyTokensRemaining: weeklyTokensRemaining ?? this.weeklyTokensRemaining,
      lastTokenUsedAt: lastTokenUsedAt ?? this.lastTokenUsedAt,
      antiGamingCooldownHours: antiGamingCooldownHours ?? this.antiGamingCooldownHours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate,
      'displayStreak': displayStreak,
      'protectorTokens': protectorTokens,
      'maxProtectorTokens': maxProtectorTokens,
      'tokensResetDate': tokensResetDate,
      'weeklyTokensUsed': weeklyTokensUsed,
      'weeklyTokenLimit': weeklyTokenLimit,
      'weeklyTokensRemaining': weeklyTokensRemaining,
      'lastTokenUsedAt': lastTokenUsedAt,
      'antiGamingCooldownHours': antiGamingCooldownHours,
    };
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] as String?,
      displayStreak: json['displayStreak'] as int? ?? 0,
      protectorTokens: json['protectorTokens'] as int? ?? 3,
      maxProtectorTokens: json['maxProtectorTokens'] as int? ?? 3,
      tokensResetDate: json['tokensResetDate'] as String?,
      weeklyTokensUsed: json['weeklyTokensUsed'] as int? ?? 0,
      weeklyTokenLimit: json['weeklyTokenLimit'] as int? ?? 3,
      weeklyTokensRemaining: json['weeklyTokensRemaining'] as int? ?? 3,
      lastTokenUsedAt: json['lastTokenUsedAt'] as String?,
      antiGamingCooldownHours: json['antiGamingCooldownHours'] as int? ?? 24,
    );
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastCompletedDate,
        displayStreak,
        protectorTokens,
        maxProtectorTokens,
        tokensResetDate,
        weeklyTokensUsed,
        weeklyTokenLimit,
        weeklyTokensRemaining,
        lastTokenUsedAt,
        antiGamingCooldownHours,
      ];
}
