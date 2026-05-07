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
    final response = await remoteDataSource.dioInstance.post(
      '/api/v1/groups/join/',
      data: {'invite_code': inviteCode.toUpperCase()},
    );
    return response.data['group_id'] as int;
  }
}