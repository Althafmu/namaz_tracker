import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({required this.dio});

  /// Converts a [DioException] into a human-readable message using the
  /// standardized `{code, detail, field_errors}` error contract.
  ///
  /// Network / timeout errors (no response body) return a friendly cold-start
  /// message. Structured errors are mapped via [ApiErrorMapper].
  static String _parseDioError(DioException e, String fallback) {
    // Network-level failures — no HTTP response available
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Server is starting up, please try again in a moment.';
    }

    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    // Parse using standardized contract
    final apiError = ApiError.fromResponse(data, statusCode: statusCode);
    final mapped = ApiErrorMapper.toUserMessage(apiError);
    if (mapped.isNotEmpty) return mapped;

    return fallback;
  }

  Future<Map<String, dynamic>> register({
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
      return response.data;
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Registration failed'));
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/login/',
        data: {'username': username, 'password': password},
      );
      // Response now contains 'access', 'refresh', and 'user' info
      return response.data;
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Login failed'));
    }
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await dio.put(
        '/api/auth/profile/',
        data: {'first_name': firstName, 'last_name': lastName},
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

  /// Logout and blacklist the refresh token.
  Future<void> logout({required String refreshToken}) async {
    try {
      await dio.post('/api/auth/logout/', data: {'refresh': refreshToken});
    } catch (e) {
      debugPrint(
        '[AuthRemoteDataSource] Logout failed or token already invalid: $e',
      );
      // We explicitly swallow this so the local logout sequence continues smoothly
      return;
    }
  }

  /// Permanently delete the current user account.
  Future<void> deleteAccount() async {
    try {
      await dio.delete('/api/auth/delete/');
    } on DioException catch (e) {
      throw Exception(_parseDioError(e, 'Account deletion failed'));
    }
  }

  /// PATCH /api/profile/offsets/ — sync manual offsets and calculation settings to cloud.
  Future<void> patchProfileOffsets(Map<String, dynamic> data) async {
    try {
      await dio.patch('/api/profile/offsets/', data: data);
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Settings sync failed';
      if (data is Map<String, dynamic>) {
        message = data['detail']?.toString() ?? data.values.first.toString();
      }
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getUserConfig() async {
    try {
      final response = await dio.get('/api/user/config/');
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Failed to get user config';
      if (data is Map<String, dynamic>) {
        message = data['detail']?.toString() ?? data.values.first.toString();
      }
      throw Exception(message);
    }
  }
}
