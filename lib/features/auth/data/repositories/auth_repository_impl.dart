import 'package:flutter/foundation.dart';
// Hide Supabase types that clash with our domain entities
import 'package:supabase_flutter/supabase_flutter.dart'
    hide User, AuthResponse;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../../../core/network/token_provider.dart';

/// Auth repository implementation.
///
/// Google Sign-In via Supabase is ACTIVE.
/// All Django-era token management and backend calls are STUBBED.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenProvider tokenProvider;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenProvider,
  });

  static const _tag = '[AuthRepositoryImpl]';

  // ── ACTIVE: Supabase Google Sign-In ──────────────────────────────────────

  @override
  Future<AuthResponse> googleSignIn({
    required String idToken,
    required String accessToken,
  }) async {
    // AuthRemoteDataSource calls AuthService.signInWithGoogleTokens + profile upsert
    await remoteDataSource.googleSignIn(
      idToken: idToken,
      accessToken: accessToken,
    );

    // Read real user from Supabase session
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser == null) {
      throw Exception('Supabase sign-in succeeded but no session found.');
    }

    final fullName =
        supabaseUser.userMetadata?['full_name'] as String? ?? '';
    final parts = fullName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final user = UserModel(
      id: supabaseUser.id,
      username: fullName,
      email: supabaseUser.email ?? '',
      firstName: firstName,
      lastName: lastName,
    );

    return AuthResponse(
      access: 'supabase_managed',
      refresh: 'supabase_managed',
      user: user,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout(refreshToken: '');
    } catch (e) {
      debugPrint('$_tag Server logout failed (non-fatal): $e');
    } finally {
      await tokenProvider.clearAll();
    }
  }

  // ── ACTIVE: Supabase Email/Password Auth ──────────────────────────────────────

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final parts = name.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final data = await remoteDataSource.register(
      username: name,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    return AuthResponse(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await remoteDataSource.login(
      username: email,
      password: password,
    );

    return AuthResponse(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
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

  @override
  Future<void> updateSettings({
    required Map<String, int> manualOffsets,
    String? calculationMethod,
    bool? useHanafi,
    String? intentLevel,
    bool? sunnahEnabled,
  }) async {
    await remoteDataSource.patchProfileOffsets({
      'manual_offsets': manualOffsets,
      'calculation_method': calculationMethod,
      'use_hanafi': useHanafi,
      'intent_level': intentLevel,
      'sunnah_enabled': sunnahEnabled,
    });
  }

  @override
  Future<Map<String, dynamic>> getUserConfig() async {
    return await remoteDataSource.getUserConfig();
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await remoteDataSource.requestPasswordReset(email: email);
  }

  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await remoteDataSource.confirmPasswordReset(
      token: token,
      newPassword: newPassword,
    );
  }

  @override
  Future<bool> verifyEmail({String? token}) async {
    debugPrint('$_tag verifyEmail() — stubbed (Django disabled)');
    return false;
  }

  /// Legacy: kept for TokenRefreshCoordinator compatibility. No-ops.
  Future<String?> refreshAccessToken() async {
    debugPrint('$_tag refreshAccessToken() — stubbed (Supabase manages sessions)');
    return null;
  }
}
