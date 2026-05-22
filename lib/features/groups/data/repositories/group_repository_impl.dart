import '../../data/datasources/group_remote_datasource.dart';
import '../../domain/repositories/group_repository.dart';
import '../../data/models/group_dashboard_model.dart';

/// Group repository — STUBBED during Supabase migration.
/// All methods return safe empty defaults. Supabase groups will be implemented
/// after prayer_logs stabilize.
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl(this.remoteDataSource);

  @override
  Future<GroupDashboardModel> getDashboard(String groupId) async {
    final data = await remoteDataSource.fetchDashboard(groupId);
    return GroupDashboardModel.fromJson(data);
  }

  @override
  Future<String> joinGroup(String inviteCode) async {
    return await remoteDataSource.joinGroup(inviteCode);
  }

  @override
  Future<List<GroupSummary>> getMyGroups() async {
    final list = await remoteDataSource.fetchMyGroups();
    return list.map((json) => GroupSummary.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> createGroup(String name) async {
    return await remoteDataSource.createGroup(name);
  }

  @override
  Future<Map<String, dynamic>> validateInviteCode(String inviteCode) async {
    return await remoteDataSource.validateInviteCode(inviteCode);
  }
}