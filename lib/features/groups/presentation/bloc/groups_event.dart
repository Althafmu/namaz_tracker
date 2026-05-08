import 'package:equatable/equatable.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object> get props => [];
}

class LoadGroups extends GroupsEvent {}

class RefreshGroups extends GroupsEvent {}