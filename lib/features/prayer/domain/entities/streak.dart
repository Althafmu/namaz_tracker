import 'package:equatable/equatable.dart';

/// Represents the user's prayer streak.
class Streak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate;
  final int displayStreak; // Streak shown during grace period (before noon)

  const Streak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.displayStreak = 0,
  });

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
    int? displayStreak,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      displayStreak: displayStreak ?? this.displayStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate,
      'displayStreak': displayStreak,
    };
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] as String?,
      displayStreak: json['displayStreak'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastCompletedDate, displayStreak];
}
