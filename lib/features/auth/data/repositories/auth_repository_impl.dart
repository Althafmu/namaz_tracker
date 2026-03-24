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
    // Generate username from email (before @)
    final username = email.split('@').first;
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
    tokenProvider.setToken(token);
    
    // If user info is in the response, use it. Otherwise, create a partial user from email.
    User user;
    if (responseData['user'] != null) {
      user = UserModel.fromJson(responseData['user']);
    } else {
      // Fallback: create a user object with available info
      user = User(
        id: 0,
        username: email.split('@').first,
        email: email,
        firstName: '',
        lastName: '',
      );
    }
    
    return AuthResponse(token: token, user: user);
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
