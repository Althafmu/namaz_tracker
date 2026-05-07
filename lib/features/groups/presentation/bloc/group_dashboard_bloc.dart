import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/group_repository.dart';
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
    emit(GroupDashboardLoading());
    try {
      final dashboard = await repository.getDashboard(event.groupId);
      emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId));
    } catch (e) {
      emit(GroupDashboardError(message: e.toString(), groupId: event.groupId));
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
      emit(GroupDashboardLoaded(dashboard: dashboard, groupId: event.groupId));
    } catch (e) {
      emit(GroupDashboardError(message: e.toString(), groupId: event.groupId));
    }
  }
}