import 'package:dio/dio.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../domain/repositories/group_repository.dart';
import '../../data/models/group_dashboard_model.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl(this.remoteDataSource);

  @override
  Future<GroupDashboardModel> getDashboard(int groupId) async {
    final json = await remoteDataSource.fetchDashboard(groupId);
    return GroupDashboardModel.fromJson(json);
  }

  @override
  Future<int> joinGroup(String inviteCode) async {
    try {
      final response = await remoteDataSource.dioInstance.post(
        '/api/v1/groups/join/',
        data: {'invite_code': inviteCode.toUpperCase()},
      );
      return response.data['group_id'] as int;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409) {
        return e.response?.data['group_id'] as int;
      }
      if (status == 403) {
        throw Exception(
          e.response?.data['detail'] ?? 'You cannot join this group',
        );
      }
      if (status == 404) {
        throw Exception('Invalid invite code');
      }
      throw Exception('Failed to join group');
    }
  }

  @override
  Future<List<GroupSummary>> getMyGroups() async {
    final json = await remoteDataSource.fetchMyGroups();
    return json.map((e) => GroupSummary.fromJson(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> createGroup(String name) async {
    final response = await remoteDataSource.dioInstance.post(
      '/api/v1/groups/create/',
      data: {'name': name},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> validateInviteCode(String inviteCode) async {
    return await remoteDataSource.validateInviteCode(inviteCode);
  }
}