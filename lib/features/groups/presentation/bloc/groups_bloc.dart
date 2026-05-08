import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/group_repository.dart';
import 'groups_event.dart';
import 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GroupRepository repository;

  GroupsBloc({required this.repository}) : super(const GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<RefreshGroups>(_onRefreshGroups);
    on<JoinGroup>(_onJoinGroup);
  }

  Future<void> _onLoadGroups(LoadGroups event, Emitter<GroupsState> emit) async {
    emit(const GroupsLoading());
    try {
      final groups = await repository.getMyGroups();
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onRefreshGroups(RefreshGroups event, Emitter<GroupsState> emit) async {
    try {
      final groups = await repository.getMyGroups();
      emit(GroupsLoaded(groups));
    } catch (e) {
      // Keep current state on refresh error - don't disrupt UX
    }
  }

  Future<void> _onJoinGroup(JoinGroup event, Emitter<GroupsState> emit) async {
    emit(const GroupsJoining());
    try {
      final groupId = await repository.joinGroup(event.inviteCode);
      emit(GroupsJoinSuccess(groupId));
      // Reload groups list in background
      add(LoadGroups());
    } catch (e) {
      emit(GroupsJoinFailure(e.toString()));
    }
  }
}