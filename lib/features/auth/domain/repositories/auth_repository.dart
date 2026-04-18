import '../entities/user.dart';

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});
}

abstract class AuthRepository {
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
  });

  Future<void> updateSettings({
    required Map<String, int> manualOffsets,
    String? calculationMethod,
    bool? useHanafi,
    String? intentLevel,
  });

  Future<Map<String, dynamic>> getUserConfig();
}
