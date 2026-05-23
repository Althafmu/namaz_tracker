import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../features/prayer/presentation/bloc/settings/settings_event.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'prayer_scheduler_service.dart';

/// Session coordinator.
///
/// Network-based config hydration from Django (_hydrateIntent) is DISABLED
/// during Supabase migration. Intent falls back to local HydratedBloc state
/// or the 'foundation' default.
class SessionCoordinator {
  final AuthBloc authBloc;
  final SettingsBloc settingsBloc;
  final AuthRepository authRepository; // kept for DI compatibility
  final PrayerSchedulerService prayerSchedulerService;
  StreamSubscription? _authSub;
  StreamSubscription? _settingsSub;
  bool? _wasExcused;

  SessionCoordinator({
    required this.authBloc,
    required this.settingsBloc,
    required this.authRepository,
    required this.prayerSchedulerService,
  }) {
    _authSub?.cancel();
    _authSub = authBloc.stream.listen((state) async {
      if (state.status == AuthStatus.loadingConfig) {
        debugPrint('[SessionCoordinator] Starting config hydration from Supabase.');
        final completer = Completer<void>();
        settingsBloc.add(LoadSettingsFromCloud(completer: completer));
        try {
          await completer.future.timeout(const Duration(seconds: 4));
        } catch (e) {
          debugPrint('[SessionCoordinator] Config hydration timed out: $e');
        }
        _applyLocalFallback();
        authBloc.add(ConfigLoadComplete());
      } else if (state.status == AuthStatus.unauthenticated) {
        settingsBloc.add(const ResetSessionScopedSettings());
        _wasExcused = null;
      }
    });

    _settingsSub?.cancel();
    _settingsSub = settingsBloc.stream.listen((state) {
      if (!state.isInitialized) return;
      if (_wasExcused != state.isExcused) {
        if (state.isExcused) {
          prayerSchedulerService.cancelAllNotifications();
        } else {
          prayerSchedulerService.scheduleNotifications(state);
        }
        _wasExcused = state.isExcused;
      }
    });
  }

  /// Apply local fallback when backend config is unavailable.
  void _applyLocalFallback() {
    if (!settingsBloc.state.isIntentSet) {
      settingsBloc.add(
        const LoadIntentFromBackend('foundation', isFallback: true),
      );
    }
    // Behavior config uses existing HydratedBloc values — no dispatch needed.
  }

  void dispose() {
    _authSub?.cancel();
    _settingsSub?.cancel();
  }
}
