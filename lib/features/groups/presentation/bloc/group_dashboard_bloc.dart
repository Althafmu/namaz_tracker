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
        emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId, isCached: true));
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
        dashboard.toJson(),
      );
      emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId, isCached: false));
    } catch (e) {
      // If we have cached data, keep showing it; otherwise show error
      if (cached != null) {
        final dashboard = GroupDashboardModel.fromJson(cached);
        emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId, isCached: true));
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
        dashboard.toJson(),
      );
      emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId, isCached: false));
    } catch (e) {
      // Keep showing current data instead of losing it on refresh error
      if (currentState is GroupDashboardLoaded) {
        emit(GroupDashboardLoaded(
          dashboard: currentState.dashboard,
          groupId: currentState.groupId,
          isCached: currentState.isCached,
          errorMessage: e.toString(),
        ));
      } else {
        emit(GroupDashboardError(message: e.toString(), groupId: event.groupId));
      }
    }
  }
}