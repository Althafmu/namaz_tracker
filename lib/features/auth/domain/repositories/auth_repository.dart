import '../entities/user.dart';

class AuthResponse {
  final String access;
  final String refresh;
  final User user;

  AuthResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });
}

abstract class AuthRepository {
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResponse> login({required String email, required String password});

  Future<AuthResponse> googleSignIn({required String idToken});

  Future<void> logout();

  Future<void> deleteAccount();

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
  });

  Future<void> updateSettings({
    required Map<String, int> manualOffsets,
    String? calculationMethod,
    bool? useHanafi,
    String? intentLevel,
    bool? sunnahEnabled,
  });

  Future<Map<String, dynamic>> getUserConfig();

  Future<void> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({required String token, required String newPassword});

  Future<bool> verifyEmail({String? token});
}
