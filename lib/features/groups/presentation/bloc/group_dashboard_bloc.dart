import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/group_repository.dart';
import '../../data/datasources/group_dashboard_cache.dart';
import '../../data/models/group_dashboard_model.dart';
import 'group_dashboard_event.dart';
import 'group_dashboard_state.dart';

class GroupDashboardBloc extends Bloc<GroupDashboardEvent, GroupDashboardState> {
  final GroupRepository repository;

  GroupDashboardBloc({
    required this.repository,
  }) : super(GroupDashboardInitial()) {
    on<LoadGroupDashboard>(_onLoadGroupDashboard);
    on<RefreshGroupDashboard>(_onRefreshGroupDashboard);
  }

  Future<void> _onLoadGroupDashboard(
    LoadGroupDashboard event,
    Emitter<GroupDashboardState> emit,
  ) async {
    // Try to show cached data first for faster perceived load
    final cached = GroupDashboardCache.getCachedDashboard(event.groupId);
    if (cached != null) {
      try {
        final dashboard = GroupDashboardModel.fromJson(cached);
        emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId));
      } catch (_) {
        emit(GroupDashboardLoading());
      }
    } else {
      emit(GroupDashboardLoading());
    }

    // Fetch fresh data
    try {
      final dashboard = await repository.getDashboard(event.groupId);
      // Cache for next time
      await GroupDashboardCache.cacheDashboard(
        event.groupId,
        _modelToJson(dashboard),
      );
      emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId));
    } catch (e) {
      // If we have cached data, keep showing it; otherwise show error
      if (cached != null) {
        final dashboard = GroupDashboardModel.fromJson(cached);
        emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId));
      } else {
        emit(GroupDashboardError(message: e.toString(), groupId: event.groupId));
      }
    }
  }

  Future<void> _onRefreshGroupDashboard(
    RefreshGroupDashboard event,
    Emitter<GroupDashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is GroupDashboardLoaded) {
      emit(GroupDashboardRefreshing(
        dashboard: currentState.dashboard,
        groupId: currentState.groupId,
      ));
    }
    try {
      final dashboard = await repository.getDashboard(event.groupId);
      await GroupDashboardCache.cacheDashboard(
        event.groupId,
        _modelToJson(dashboard),
      );
      emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId));
    } catch (e) {
      if (currentState is GroupDashboardLoaded) {
        emit(GroupDashboardError(
          message: e.toString(),
          groupId: event.groupId,
        ));
      } else {
        emit(GroupDashboardError(message: e.toString(), groupId: event.groupId));
      }
    }
  }

  Map<String, dynamic> _modelToJson(GroupDashboardModel model) {
    return {
      'group': {
        'id': model.group.id,
        'name': model.group.name,
        'description': model.group.description,
        'privacy_level': model.group.privacyLevel,
        'member_count': model.group.memberCount,
        'created_by': model.group.createdBy,
      },
      'current_user': model.currentUser != null
          ? {
              'role': model.currentUser!.role,
              'joined_at': model.currentUser!.joinedAt.toIso8601String(),
              'current_streak': model.currentUser!.currentStreak,
              'rank': model.currentUser!.rank,
              'user_id': model.currentUser!.userId,
              'username': model.currentUser!.username,
            }
          : null,
      'top_streaks': model.topStreaks
          .map((e) => {'rank': e.rank, 'username': e.username, 'streak': e.streak})
          .toList(),
      'today_completion': {
        'fajr': model.todayCompletion.fajr,
        'dhuhr': model.todayCompletion.dhuhr,
        'asr': model.todayCompletion.asr,
        'maghrib': model.todayCompletion.maghrib,
        'isha': model.todayCompletion.isha,
      },
      'recent_activity': model.recentActivity
          .map((e) => {
                'type': e.type,
                'username': e.username,
                'created_at': e.timestamp.toIso8601String(),
                'message': e.message,
              })
          .toList(),
      'stats': {'weekly_completion': model.weeklyCompletion},
    };
  }
}