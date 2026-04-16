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
/// Phase 2: Includes protector tokens for streak freeze system.
class Streak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate;
  final int displayStreak;

  // Phase 2: Streak protection
  final int protectorTokens;
  final int maxProtectorTokens;
  final String? tokensResetDate;

  const Streak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.displayStreak = 0,
    this.protectorTokens = 3,
    this.maxProtectorTokens = 3,
    this.tokensResetDate,
  });

  bool get hasProtectorTokens => protectorTokens > 0;

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
    int? displayStreak,
    int? protectorTokens,
    int? maxProtectorTokens,
    String? tokensResetDate,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      displayStreak: displayStreak ?? this.displayStreak,
      protectorTokens: protectorTokens ?? this.protectorTokens,
      maxProtectorTokens: maxProtectorTokens ?? this.maxProtectorTokens,
      tokensResetDate: tokensResetDate ?? this.tokensResetDate,
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
      ];
}
