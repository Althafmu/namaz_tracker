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
    on<ConfirmGroupJoin>(_onConfirmGroupJoin);
    on<CancelGroupJoin>(_onCancelGroupJoin);
    on<CreateGroup>(_onCreateGroup);
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
    emit(const GroupsInviteValidating());
    try {
      final result = await repository.validateInviteCode(event.inviteCode);
      final groupId = result['group_id'] as int;
      final groupName = result['group_name'] as String;
      final isAlreadyMember = result['is_already_member'] as bool? ?? false;

      if (isAlreadyMember) {
        emit(GroupsJoinSuccess(groupId));
        add(LoadGroups());
      } else {
        emit(GroupsInviteConfirmed(groupId: groupId, groupName: groupName));
      }
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Failed to validate invite code';
      emit(GroupsInviteError(msg));
    }
  }

  Future<void> _onConfirmGroupJoin(ConfirmGroupJoin event, Emitter<GroupsState> emit) async {
    emit(const GroupsJoining());
    try {
      final groupId = await repository.joinGroup(event.inviteCode);
      emit(GroupsJoinSuccess(groupId));
      add(LoadGroups());
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Failed to join group';
      emit(GroupsJoinFailure(msg));
    }
  }

  Future<void> _onCancelGroupJoin(CancelGroupJoin event, Emitter<GroupsState> emit) async {
    try {
      final groups = await repository.getMyGroups();
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(const GroupsLoaded([]));
    }
  }

  Future<void> _onCreateGroup(CreateGroup event, Emitter<GroupsState> emit) async {
    emit(const GroupsCreating());
    try {
      final data = await repository.createGroup(event.name);
      final groupId = data['id'] as int;
      final inviteCode = data['invite_code'] as String;
      emit(GroupsCreateSuccess(groupId, inviteCode));
      add(LoadGroups());
    } catch (e) {
      emit(GroupsCreateFailure(e.toString()));
    }
  }
}