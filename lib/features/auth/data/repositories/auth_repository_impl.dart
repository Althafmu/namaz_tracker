import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../../../core/network/token_provider.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenProvider tokenProvider;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenProvider,
  });

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Use the full email as username (server can generate its own if needed)
    // Finding #7: removed predictable email.split('@').first derivation
    final username = email;
    // Split name into first and last for Django user model
    final names = name.split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    return await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final responseData = await remoteDataSource.login(username: email, password: password);
    final token = responseData['access'] as String;
    final refreshToken = responseData['refresh'] as String?;

    // Persist both tokens atomically via single write path
    await tokenProvider.updateTokens(access: token, refresh: refreshToken);

    // Finding #10: throw if server omits user data instead of creating phantom user
    User user;
    if (responseData['user'] != null) {
      user = UserModel.fromJson(responseData['user']);
    } else {
      debugPrint('[AuthRepo] Server response missing user field — creating minimal user from email');
      throw Exception('Login succeeded but server did not return user profile. Please try again.');
    }

    return AuthResponse(token: token, user: user);
  }

  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns the new access token, or null if refresh failed.
  Future<String?> refreshAccessToken() async {
    final currentRefresh = tokenProvider.refreshToken;
    if (currentRefresh == null) return null;

    try {
      final newAccess = await remoteDataSource.refreshToken(refreshToken: currentRefresh);
      await tokenProvider.updateAccessToken(newAccess);
      return newAccess;
    } catch (e) {
      debugPrint('[AuthRepo] Token refresh failed: $e');
      return null;
    }
  }

  @override
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    return await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
    );
  }
}
