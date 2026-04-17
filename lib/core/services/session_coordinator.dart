import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    const int maxRetries = 3;
    const int baseDelayMs = 1000;
    final random = Random();

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final config = await authRepository.getUserConfig();
        final intent = config['data']?['intent_level'];
        if (intent != null) {
          settingsBloc.add(LoadIntentFromBackend(intent));
        } else if (!settingsBloc.state.isIntentSet) {
          settingsBloc.add(const LoadIntentFromBackend('foundation', isFallback: true));
        }
        return; // Success, exit retry loop
      } catch (e) {
        bool shouldRetry = false;
        
        if (e is DioException) {
          final statusCode = e.response?.statusCode;
          // Retry on network/timeout errors or 5xx server errors
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError ||
              (statusCode != null && statusCode >= 500)) {
            shouldRetry = true;
          }
          // Do not retry 400, 401, 403, 404, etc.
        } else if (e is SocketException || e is TimeoutException) {
          shouldRetry = true;
        }

        if (attempt == maxRetries - 1 || !shouldRetry) {
          debugPrint('[SessionCoordinator] Config fetch failed permanently: $e');
          if (!settingsBloc.state.isIntentSet) {
            settingsBloc.add(const LoadIntentFromBackend('foundation', isFallback: true));
          }
          return;
        }

        // Exponential backoff with jitter
        final delayMs = (baseDelayMs * pow(2, attempt)).toInt() + random.nextInt(300);
        debugPrint('[SessionCoordinator] Config fetch failed (attempt ${attempt + 1}). Retrying in ${delayMs}ms...');
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  void dispose() {
    _authSub?.cancel();
  }
}
