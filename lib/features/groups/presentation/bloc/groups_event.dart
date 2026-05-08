import 'package:equatable/equatable.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object> get props => [];
}

class LoadGroups extends GroupsEvent {}

class RefreshGroups extends GroupsEvent {}

class JoinGroup extends GroupsEvent {
  final String inviteCode;
  const JoinGroup(this.inviteCode);

  @override
  List<Object> get props => [inviteCode];
}