import 'package:equatable/equatable.dart';

class GroupDashboard extends Equatable {
  final int groupId;
  final String groupName;
  final String privacyLevel;
  final int memberCount;
  final CurrentUserDashboard? currentUser;
  final List<LeaderboardEntry> topStreaks;
  final TodayCompletion todayCompletion;

  const GroupDashboard({
    required this.groupId,
    required this.groupName,
    required this.privacyLevel,
    required this.memberCount,
    this.currentUser,
    required this.topStreaks,
    required this.todayCompletion,
  });

  @override
  List<Object?> get props => [
        groupId,
        groupName,
        privacyLevel,
        memberCount,
        currentUser,
        topStreaks,
        todayCompletion,
      ];
}

class CurrentUserDashboard extends Equatable {
  final String role;
  final int currentStreak;
  final int? rank;

  const CurrentUserDashboard({
    required this.role,
    required this.currentStreak,
    this.rank,
  });

  @override
  List<Object?> get props => [role, currentStreak, rank];
}

class LeaderboardEntry extends Equatable {
  final int rank;
  final String username;
  final int streak;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.streak,
  });

  @override
  List<Object?> get props => [rank, username, streak];
}

class TodayCompletion extends Equatable {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const TodayCompletion({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  int get total => fajr + dhuhr + asr + maghrib + isha;

  @override
  List<Object?> get props => [fajr, dhuhr, asr, maghrib, isha];
}