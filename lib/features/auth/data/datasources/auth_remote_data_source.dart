import 'package:dio/dio.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({required this.dio});

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Registration failed';
      if (data is Map<String, dynamic>) {
        message = data['detail']?.toString() ?? data.values.first.toString();
      }
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/login/',
        data: {
          'username': username,
          'password': password,
        },
      );
      // Response now contains 'access', 'refresh', and 'user' info
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Login failed';
      if (data is Map<String, dynamic>) {
        message = data['detail']?.toString() ?? data.values.first.toString();
      }
      throw Exception(message);
    }
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await dio.put(
        '/api/auth/profile/',
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Profile update failed';
      if (data is Map<String, dynamic>) {
        message = data['detail']?.toString() ?? data.values.first.toString();
      }
      throw Exception(message);
    }
  }

  /// Refresh the access token using a refresh token.
  /// Returns the new access token string.
  Future<String> refreshToken({required String refreshToken}) async {
    try {
      final response = await dio.post(
        '/api/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );
      return response.data['access'] as String;
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Token refresh failed';
      if (data is Map<String, dynamic>) {
        message = data['detail']?.toString() ?? data.values.first.toString();
      }
      throw Exception(message);
    }
  }
}
