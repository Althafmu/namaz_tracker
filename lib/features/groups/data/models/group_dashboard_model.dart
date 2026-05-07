import 'package:equatable/equatable.dart';

class GroupDashboardModel extends Equatable {
  final GroupSummary group;
  final CurrentUserStats? currentUser;
  final List<LeaderboardEntry> topStreaks;
  final TodayCompletionStats todayCompletion;
  final List<ActivityItem> recentActivity;
  final int weeklyCompletion;

  const GroupDashboardModel({
    required this.group,
    this.currentUser,
    required this.topStreaks,
    required this.todayCompletion,
    required this.recentActivity,
    required this.weeklyCompletion,
  });

  factory GroupDashboardModel.fromJson(Map<String, dynamic> json) {
    return GroupDashboardModel(
      group: GroupSummary.fromJson(json['group'] as Map<String, dynamic>),
      currentUser: json['current_user'] != null
          ? CurrentUserStats.fromJson(json['current_user'] as Map<String, dynamic>)
          : null,
      topStreaks: (json['top_streaks'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      todayCompletion:
          TodayCompletionStats.fromJson(json['today_completion'] as Map<String, dynamic>),
      recentActivity: json['recent_activity'] != null
          ? (json['recent_activity'] as List<dynamic>)
              .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      weeklyCompletion: json['stats']?['weekly_completion'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [group, currentUser, topStreaks, todayCompletion, recentActivity, weeklyCompletion];
}

class GroupSummary extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String privacyLevel;
  final int memberCount;
  final String createdBy;

  const GroupSummary({
    required this.id,
    required this.name,
    this.description,
    required this.privacyLevel,
    required this.memberCount,
    required this.createdBy,
  });

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    return GroupSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      privacyLevel: json['privacy_level'] as String,
      memberCount: json['member_count'] as int,
      createdBy: json['created_by'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, description, privacyLevel, memberCount, createdBy];
}

class CurrentUserStats extends Equatable {
  final int? userId;
  final String role;
  final DateTime joinedAt;
  final int currentStreak;
  final int? rank;

  const CurrentUserStats({
    this.userId,
    required this.role,
    required this.joinedAt,
    required this.currentStreak,
    this.rank,
  });

  factory CurrentUserStats.fromJson(Map<String, dynamic> json) {
    return CurrentUserStats(
      userId: json['user_id'] as int?,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      currentStreak: json['current_streak'] as int,
      rank: json['rank'] as int?,
    );
  }

  @override
  List<Object?> get props => [userId, role, joinedAt, currentStreak, rank];
}

class LeaderboardEntry extends Equatable {
  final int rank;
  final String username;
  final int streak;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.streak,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      username: json['username'] as String,
      streak: json['streak'] as int? ?? 0,
    );
  }

  LeaderboardEntry copyWith({bool? isCurrentUser}) {
    return LeaderboardEntry(
      rank: rank,
      username: username,
      streak: streak,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  @override
  List<Object?> get props => [rank, username, streak, isCurrentUser];
}

class TodayCompletionStats extends Equatable {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const TodayCompletionStats({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory TodayCompletionStats.fromJson(Map<String, dynamic> json) {
    return TodayCompletionStats(
      fajr: json['fajr'] as int? ?? 0,
      dhuhr: json['dhuhr'] as int? ?? 0,
      asr: json['asr'] as int? ?? 0,
      maghrib: json['maghrib'] as int? ?? 0,
      isha: json['isha'] as int? ?? 0,
    );
  }

  int get total => fajr + dhuhr + asr + maghrib + isha;

  @override
  List<Object?> get props => [fajr, dhuhr, asr, maghrib, isha];
}

class ActivityItem extends Equatable {
  final String id;
  final String type;
  final String message;
  final String? username;
  final DateTime timestamp;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.message,
    this.username,
    required this.timestamp,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String,
      message: json['message'] as String,
      username: json['username'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, type, message, username, timestamp];
}