import 'package:equatable/equatable.dart';
import '../../data/models/group_dashboard_model.dart';

abstract class GroupDashboardState extends Equatable {
  const GroupDashboardState();

  @override
  List<Object?> get props => [];
}

class GroupDashboardInitial extends GroupDashboardState {}

class GroupDashboardLoading extends GroupDashboardState {}

class GroupDashboardLoaded extends GroupDashboardState {
  final GroupDashboardModel dashboard;
  final String groupId;
  final bool isCached;
  final String? errorMessage;

  const GroupDashboardLoaded({
    required this.dashboard,
    required this.groupId,
    required this.isCached,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [dashboard, groupId, isCached, errorMessage];
}

class GroupDashboardError extends GroupDashboardState {
  final String message;
  final String? groupId;

  const GroupDashboardError({
    required this.message,
    this.groupId,
  });

  @override
  List<Object?> get props => [message, groupId];
}

class GroupDashboardRefreshing extends GroupDashboardState {
  final GroupDashboardModel dashboard;
  final String groupId;

  const GroupDashboardRefreshing({
    required this.dashboard,
    required this.groupId,
  });

  @override
  List<Object?> get props => [dashboard, groupId];
}