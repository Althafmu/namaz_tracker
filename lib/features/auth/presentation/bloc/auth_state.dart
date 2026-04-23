import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../data/models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error, loadingConfig, emailVerificationPending }

/// Sentinel used by [copyWith] to explicitly set a nullable field to null.
class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool hasSeenOnboarding;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.hasSeenOnboarding = false,
  });

  factory AuthState.initial() => const AuthState(
        status: AuthStatus.unknown,
        hasSeenOnboarding: false,
      );

  /// Use sentinel pattern to allow explicitly setting nullable fields to null.
  AuthState copyWith({
    AuthStatus? status,
    Object? user = _undefined,
    Object? errorMessage = _undefined,
    bool? hasSeenOnboarding,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user == _undefined ? this.user : user as User?,
      errorMessage: errorMessage == _undefined ? this.errorMessage : errorMessage as String?,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  // Hydration logic — token is NO LONGER persisted here (stored in flutter_secure_storage)
  factory AuthState.fromJson(Map<String, dynamic> json) {
    final isAuthenticated = json['isAuthenticated'] as bool? ?? false;
    final userData = json['user'] as Map<String, dynamic>?;

    return AuthState(
      status: isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated,
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
      'isAuthenticated': status == AuthStatus.authenticated,
      'user': userData,
      'hasSeenOnboarding': hasSeenOnboarding,
    };
  }

  @override
  List<Object?> get props => [status, user, errorMessage, hasSeenOnboarding];
}
