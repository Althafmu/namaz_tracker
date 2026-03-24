import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/token_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final TokenProvider tokenProvider;

  AuthBloc({
    required this.authRepository,
    required this.tokenProvider,
  }) : super(AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<InitAuthRequested>(_onInitAuthRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final response = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      // Sync token to TokenProvider so Dio interceptor can use it
      tokenProvider.setToken(response.token);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        token: response.token,
        user: response.user,
        errorMessage: null,
        hasSeenOnboarding: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      // Store user info and then log in
      emit(state.copyWith(user: user));
      add(LoginRequested(email: event.email, password: event.password));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    tokenProvider.setToken(null);
    // Explicitly null-out token, user, and errorMessage using sentinel copyWith
    emit(const AuthState(
      status: AuthStatus.unauthenticated,
      token: null,
      user: null,
      errorMessage: null,
      hasSeenOnboarding: true, // preserve onboarding seen status
    ));
  }

  void _onInitAuthRequested(InitAuthRequested event, Emitter<AuthState> emit) {
    // Already handled token sync in constructor, just ensure state reflects truth
    if (state.token != null) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    // Optimistic local update
    final updatedUser = UserModel(
      id: currentUser.id,
      username: currentUser.username,
      email: currentUser.email,
      firstName: event.firstName,
      lastName: event.lastName,
    );
    emit(state.copyWith(user: updatedUser));

    // Sync with backend (best-effort — works offline via HydratedBloc)
    try {
      final serverUser = await authRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(state.copyWith(user: serverUser));
    } catch (_) {
      // Offline or API error — keep the optimistic local update
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    final restoredState = AuthState.fromJson(json);
    tokenProvider.setToken(restoredState.token);
    return restoredState;
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toJson();
  }
}
