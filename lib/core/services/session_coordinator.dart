import 'dart:async';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../features/prayer/presentation/bloc/settings/settings_event.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class SessionCoordinator {
  final AuthBloc authBloc;
  final SettingsBloc settingsBloc;
  final AuthRepository authRepository;
  StreamSubscription? _authSub;

  SessionCoordinator({
    required this.authBloc,
    required this.settingsBloc,
    required this.authRepository,
  }) {
    _authSub = authBloc.stream.listen((state) async {
      if (state.status == AuthStatus.loadingConfig) {
        await _hydrateIntent();
        authBloc.add(ConfigLoadComplete());
      }
    });
  }

  Future<void> _hydrateIntent() async {
    try {
      final config = await authRepository.getUserConfig();
      final intent = config['data']?['intent_level'];
      if (intent != null) {
        settingsBloc.add(LoadIntentFromBackend(intent));
      } else if (!settingsBloc.state.isIntentSet) {
        settingsBloc.add(const LoadIntentFromBackend('foundation', isFallback: true));
      }
    } catch (_) {
      if (!settingsBloc.state.isIntentSet) {
        settingsBloc.add(const LoadIntentFromBackend('foundation', isFallback: true));
      }
    }
  }

  void dispose() {
    _authSub?.cancel();
  }
}
