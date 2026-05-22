import 'package:equatable/equatable.dart';

abstract class GroupDashboardEvent extends Equatable {
  const GroupDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupDashboard extends GroupDashboardEvent {
  final String groupId;

  const LoadGroupDashboard(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class RefreshGroupDashboard extends GroupDashboardEvent {
  final String groupId;

  const RefreshGroupDashboard(this.groupId);

  @override
  List<Object?> get props => [groupId];
}