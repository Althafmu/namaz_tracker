import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../data/models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

/// Sentinel used by [copyWith] to explicitly set a nullable field to null.
class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

class AuthState extends Equatable {
  final AuthStatus status;
  final String? token;
  final User? user;
  final String? errorMessage;
  final bool hasSeenOnboarding;

  const AuthState({
    required this.status,
    this.token,
    this.user,
    this.errorMessage,
    this.hasSeenOnboarding = false,
  });

  factory AuthState.initial() => const AuthState(
        status: AuthStatus.unknown,
        hasSeenOnboarding: false,
      );

  /// Use [clearToken], [clearUser], [clearErrorMessage] to explicitly null out
  /// nullable fields. Passing `null` for these fields preserves the current value.
  AuthState copyWith({
    AuthStatus? status,
    Object? token = _undefined,
    Object? user = _undefined,
    Object? errorMessage = _undefined,
    bool? hasSeenOnboarding,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token == _undefined ? this.token : token as String?,
      user: user == _undefined ? this.user : user as User?,
      errorMessage: errorMessage == _undefined ? this.errorMessage : errorMessage as String?,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  // Hydration logic
  factory AuthState.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    final userData = json['user'] as Map<String, dynamic>?;
    
    return AuthState(
      status: token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      token: token,
      user: userData != null ? UserModel.fromJson(userData) : null,
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? userData;
    if (user != null) {
      if (user is UserModel) {
        userData = (user as UserModel).toJson();
      } else {
        // Manually serialize a plain User entity
        userData = {
          'id': user!.id,
          'username': user!.username,
          'email': user!.email,
          'first_name': user!.firstName,
          'last_name': user!.lastName,
        };
      }
    }
    return {
      'token': token,
      'user': userData,
      'hasSeenOnboarding': hasSeenOnboarding,
    };
  }

  @override
  List<Object?> get props => [status, token, user, errorMessage, hasSeenOnboarding];
}
