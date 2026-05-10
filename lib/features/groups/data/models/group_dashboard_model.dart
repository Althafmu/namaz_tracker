import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
    try {
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
    } catch (e, stack) {
      debugPrint('PARSE ERROR in GroupDashboardModel.fromJson: $e');
      debugPrint('JSON: $json');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'group': group.toJson(),
    'current_user': currentUser?.toJson(),
    'top_streaks': topStreaks.map((e) => e.toJson()).toList(),
    'today_completion': todayCompletion.toJson(),
    'recent_activity': recentActivity.map((e) => e.toJson()).toList(),
    'stats': {'weekly_completion': weeklyCompletion},
  };

  @override
  List<Object?> get props => [group, currentUser, topStreaks, todayCompletion, recentActivity, weeklyCompletion];
}

class GroupSummary extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String privacyLevel;
  final int memberCount;
  final String? createdBy;
  final String? userRole;
  final String? inviteCode;

  const GroupSummary({
    required this.id,
    required this.name,
    this.description,
    required this.privacyLevel,
    required this.memberCount,
    this.createdBy,
    this.userRole,
    this.inviteCode,
  });

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    return GroupSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      privacyLevel: json['privacy_level'] as String,
      memberCount: json['member_count'] as int,
      createdBy: json['created_by'] as String?,
      userRole: json['user_role'] as String?,
      inviteCode: json['invite_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'privacy_level': privacyLevel,
        'member_count': memberCount,
        'created_by': createdBy,
        'user_role': userRole,
        'invite_code': inviteCode,
      };

  @override
  List<Object?> get props => [id, name, description, privacyLevel, memberCount, createdBy, userRole];
}

class CurrentUserStats extends Equatable {
  final int? userId;
  final String? username;
  final String role;
  final DateTime joinedAt;
  final int currentStreak;
  final int? rank;

  const CurrentUserStats({
    this.userId,
    this.username,
    required this.role,
    required this.joinedAt,
    required this.currentStreak,
    this.rank,
  });

  factory CurrentUserStats.fromJson(Map<String, dynamic> json) {
    return CurrentUserStats(
      userId: json['user_id'] as int?,
      username: json['username'] as String?,
      role: json['role'] as String,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      currentStreak: json['current_streak'] as int? ?? 0,
      rank: json['rank'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'username': username,
    'role': role,
    'joined_at': joinedAt.toIso8601String(),
    'current_streak': currentStreak,
    'rank': rank,
  };

  @override
  List<Object?> get props => [userId, username, role, joinedAt, currentStreak, rank];
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

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'username': username,
    'streak': streak,
  };

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

  Map<String, dynamic> toJson() => {
    'fajr': fajr,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
  };

  int get total => fajr + dhuhr + asr + maghrib + isha;

  @override
  List<Object?> get props => [fajr, dhuhr, asr, maghrib, isha];
}

class ActivityItem extends Equatable {
  final String? id;
  final String type;
  final String? message;
  final String? username;
  final DateTime? timestamp;

  const ActivityItem({
    this.id,
    required this.type,
    this.message,
    this.username,
    this.timestamp,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String?,
      type: json['type'] as String,
      message: json['message'] as String?,
      username: json['username'] as String?,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'message': message,
        'username': username,
        'timestamp': timestamp?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, type, message, username, timestamp];
}