import 'package:equatable/equatable.dart';

/// Represents the user's prayer streak.
class Streak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final String? lastCompletedDate;

  const Streak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
  });

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate,
    };
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] as String?,
    );
  }

  @override
  List<Object?> get props => [currentStreak, longestStreak, lastCompletedDate];
}
