import 'package:equatable/equatable.dart';
import '../../data/models/group_dashboard_model.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object?> get props => [];
}

class GroupsInitial extends GroupsState {
  const GroupsInitial();
}

class GroupsLoading extends GroupsState {
  const GroupsLoading();
}

class GroupsLoaded extends GroupsState {
  final List<GroupSummary> groups;

  const GroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupsError extends GroupsState {
  final String message;

  const GroupsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupsJoining extends GroupsState {
  const GroupsJoining();
}

class GroupsJoinSuccess extends GroupsState {
  final String groupId;
  const GroupsJoinSuccess(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class GroupsJoinFailure extends GroupsState {
  final String message;
  const GroupsJoinFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupsCreating extends GroupsState {
  const GroupsCreating();
}

class GroupsCreateSuccess extends GroupsState {
  final String groupId;
  final String inviteCode;
  const GroupsCreateSuccess(this.groupId, this.inviteCode);

  @override
  List<Object?> get props => [groupId, inviteCode];
}

class GroupsCreateFailure extends GroupsState {
  final String message;
  const GroupsCreateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupsInviteValidating extends GroupsState {
  const GroupsInviteValidating();
}

class GroupsInviteConfirmed extends GroupsState {
  final String groupId;
  final String groupName;
  const GroupsInviteConfirmed({required this.groupId, required this.groupName});

  @override
  List<Object?> get props => [groupId, groupName];
}

class GroupsInviteError extends GroupsState {
  final String message;
  const GroupsInviteError(this.message);

  @override
  List<Object?> get props => [message];
}