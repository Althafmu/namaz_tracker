import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/token_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final TokenProvider tokenProvider;

  /// Strip the 'Exception: ' prefix from error messages for cleaner display.
  static String _cleanError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ') ? msg.substring(11) : msg;
  }

  AuthBloc({required this.authRepository, required this.tokenProvider})
    : super(AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<InitAuthRequested>(_onInitAuthRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ConfigLoadComplete>(_onConfigLoadComplete);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordResetConfirmed>(_onPasswordResetConfirmed);
    on<EmailVerificationRequested>(_onEmailVerificationRequested);
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

      // Token is persisted in secure storage by the repository/tokenProvider
      emit(
        state.copyWith(
          status: AuthStatus.loadingConfig,
          user: response.user,
          errorMessage: null,
          hasSeenOnboarding: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: _cleanError(e)),
      );
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null),
      );
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final response = await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      // Wait for email verification before loading config
      emit(
        state.copyWith(
          status: AuthStatus.emailVerificationPending,
          user: response.user,
          errorMessage: null,
          hasSeenOnboarding: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: _cleanError(e)),
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Tell backend to blacklist the token
    await authRepository.logout();

    // 2. Erase local tokens permanently
    await tokenProvider.clearAll();

    // 3. Emit unauthenticated state immediately so router reacts
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
        hasSeenOnboarding: true, // preserve onboarding seen status
      ),
    );
  }

  Future<void> _onInitAuthRequested(
    InitAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Do nothing if config hydration is already in progress (e.g. splash page
    // 1.5 s delay fires a second InitAuthRequested while SessionCoordinator is
    // still fetching user config — prevents the splash/config loop).
    if (state.status == AuthStatus.loading ||
        state.status == AuthStatus.loadingConfig ||
        state.status == AuthStatus.authenticated) {
      return;
    }

    // Token lives in secure storage, not in HydratedBloc state
    await tokenProvider.loadTokens();
    if (tokenProvider.token != null) {
      emit(state.copyWith(status: AuthStatus.loadingConfig));
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

  void _onConfigLoadComplete(
    ConfigLoadComplete event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(status: AuthStatus.authenticated));
  }

  void _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(hasSeenOnboarding: true));
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await authRepository.requestPasswordReset(email: event.email);
      emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: _cleanError(e)));
      emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null));
    }
  }

  Future<void> _onPasswordResetConfirmed(
    PasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await authRepository.confirmPasswordReset(
        token: event.token,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: _cleanError(e)));
      emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null));
    }
  }

  Future<void> _onEmailVerificationRequested(
    EmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.token == null || event.token!.isEmpty) return;
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final success = await authRepository.verifyEmail(token: event.token);
      if (success) {
        emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: _cleanError(e)));
      emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null));
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      final restoredState = AuthState.fromJson(json);
      // Token is loaded via InitAuthRequested, not from HydratedBloc JSON
      return restoredState;
    } catch (e) {
      // Corrupted storage from a previous version — start fresh
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toJson();
  }
}
