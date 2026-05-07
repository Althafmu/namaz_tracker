import 'package:dio/dio.dart';

class GroupRemoteDataSource {
  final Dio dio;

  GroupRemoteDataSource({required this.dio});

  Future<Map<String, dynamic>> fetchDashboard(int groupId) async {
    final response = await dio.get('/api/v1/groups/$groupId/dashboard/');
    return response.data as Map<String, dynamic>;
  }
}