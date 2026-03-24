import '../entities/user.dart';

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});
}

abstract class AuthRepository {
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<User> updateProfile({
    required String firstName,
    required String lastName,
  });
}
