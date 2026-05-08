import 'package:dio/dio.dart';

class GroupRemoteDataSource {
  final Dio dio;

  GroupRemoteDataSource({required this.dio});

  Dio get dioInstance => dio;

  Future<Map<String, dynamic>> fetchDashboard(int groupId) async {
    final response = await dio.get('/api/v1/groups/$groupId/dashboard/');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchGroupActivity(int groupId) async {
    final response = await dio.get('/api/v1/groups/$groupId/activity/');
    final data = response.data as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMyGroups() async {
    final response = await dio.get('/api/v1/groups/my/');
    final data = response.data as List<dynamic>;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}