import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../features/prayer/presentation/bloc/settings/settings_state.dart';
import '../../features/prayer/presentation/pages/home/home_page.dart';
import '../../features/prayer/presentation/pages/progress/progress_page.dart';
import '../../features/prayer/presentation/pages/profile/settings_page.dart';
import '../../features/prayer/presentation/pages/streak/streak_page.dart';
import '../../features/prayer/presentation/pages/settings/settings_main_page.dart';
import '../../features/prayer/presentation/pages/settings/notifications_settings_page.dart';
import '../../features/prayer/presentation/pages/settings/calculation_settings_page.dart';
import '../../features/prayer/presentation/pages/settings/reasons_settings_page.dart';
import '../../features/prayer/presentation/bloc/settings/settings_bloc.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding1_page.dart';
import '../../features/auth/presentation/pages/onboarding_psych_page.dart';
import '../../features/auth/presentation/pages/intent_onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/password_reset_request_page.dart';
import '../../features/auth/presentation/pages/password_reset_confirm_page.dart';
import '../../features/auth/presentation/pages/email_verification_pending_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/prayer/presentation/bloc/history/history_bloc.dart';
import '../../features/prayer/presentation/bloc/history/history_event.dart';
import '../../features/prayer/presentation/bloc/history/history_state.dart';

/// A [Listenable] that notifies when the [AuthBloc] or [SettingsBloc] state changes.
class AppRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<AuthState> _authSub;
  late final StreamSubscription<SettingsState> _settingsSub;

  AppRefreshListenable(AuthBloc authBloc, SettingsBloc settingsBloc) {
    _authSub = authBloc.stream.listen((state) {
      notifyListeners();
    });
    _settingsSub = settingsBloc.stream.listen((state) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _settingsSub.cancel();
    super.dispose();
  }
}

GoRouter buildAppRouter(AuthBloc authBloc, SettingsBloc settingsBloc) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: AppRefreshListenable(authBloc, settingsBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final status = authState.status;
      final loggingIn = state.uri.path == '/login';
      final signingUp = state.uri.path == '/signup';
      final splash = state.uri.path == '/splash';
      final onboarding = state.uri.path.startsWith('/onboarding');
      final intentSetup = state.uri.path == '/intent-setup';
      final emailVerifying = state.uri.path == '/email-verification';

      // While bootstrapping from storage, ensure we stay on splash.
      if (status == AuthStatus.unknown) {
        return splash ? null : '/splash';
      }

      final passwordResetting = state.uri.path.startsWith('/password-reset');

      // During login/register/reset, keep the user on the auth screen spinner instead
      // of bouncing through splash again.
      if (status == AuthStatus.loading) {
        if (splash || loggingIn || signingUp || passwordResetting) {
          return null;
        }
        return '/splash';
      }

      // While config is being hydrated after a successful login/register:
      // - Stay on splash if coming from a fresh app start (already on splash).
      // - Stay in place on auth screens so the loading spinner remains visible.
      // - Redirect to splash if somehow on a protected route (e.g. expired-session).
      if (status == AuthStatus.loadingConfig) {
        if (splash || loggingIn || signingUp || onboarding || intentSetup || passwordResetting) {
          return null;
        }
        return '/splash';
      }

      // If authenticated, don't allow login/signup/onboarding/splash/intent-setup
      if (status == AuthStatus.authenticated) {
        final isIntentSet = settingsBloc.state.isIntentSet;

        if (!isIntentSet && !intentSetup) {
          return '/intent-setup';
        } else if (isIntentSet && intentSetup) {
          return '/';
        }

        if (loggingIn || signingUp || onboarding || splash || emailVerifying) {
          return '/';
        }
        return null;
      }

      if (status == AuthStatus.emailVerificationPending) {
        if (emailVerifying) {
          return null;
        }
        return '/email-verification';
      }

      // If unauthenticated, redirect to login unless on signup/onboarding/password-reset
      if (status == AuthStatus.unauthenticated) {
        if (splash) {
          return authState.hasSeenOnboarding ? '/login' : '/onboarding1';
        }
        if (loggingIn || signingUp || onboarding || passwordResetting) {
          return null;
        }
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding1',
        builder: (context, state) => const Onboarding1Page(),
      ),
      GoRoute(
        path: '/onboarding-psych',
        builder: (context, state) => const OnboardingPsychPage(),
      ),
      GoRoute(
        path: '/intent-setup',
        builder: (context, state) => const IntentOnboardingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(path: '/email-verification', builder: (context, state) => const EmailVerificationPendingPage()),
      GoRoute(path: '/password-reset', builder: (context, state) => const PasswordResetRequestPage()),
      GoRoute(
        path: '/password-reset/confirm',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return PasswordResetConfirmPage(token: token);
        },
      ),
      GoRoute(path: '/streak', builder: (context, state) => const StreakPage()),
      // ── Full-screen settings routes (outside shell — no bottom nav) ──
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsMainPage(),
      ),
      GoRoute(
        path: '/settings/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsSettingsPage(),
      ),
      GoRoute(
        path: '/settings/calculation',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CalculationSettingsPage(),
      ),
      GoRoute(
        path: '/settings/reasons',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ReasonsSettingsPage(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProgressPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
  );
}

/// App shell with Neo-brutalist bottom navigation bar.
class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (offline != _isOffline) {
        setState(() => _isOffline = offline);
      }
    });
    // Check initial status
    Connectivity().checkConnectivity().then((results) {
      if (mounted) {
        final offline = results.every((r) => r == ConnectivityResult.none);
        if (offline != _isOffline) {
          setState(() => _isOffline = offline);
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/progress')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final index = _currentIndex(context);

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: Column(
          children: [
            // ── Offline Banner ──
            if (_isOffline)
              Material(
                color: Colors.orange.shade800,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You are offline. Changes will sync when reconnected.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.border, width: 2)),
            boxShadow: [
              BoxShadow(
                color: c.border,
                offset: const Offset(0, -4),
                blurRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home,
                      label: 'HOME',
                      isActive: index == 0,
                      onTap: () {
                        GetIt.I<HistoryBloc>().add(
                          SelectDate(HistoryState.todayKey),
                        );
                        context.go('/');
                      },
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.trending_up,
                      label: 'PROGRESS',
                      isActive: index == 1,
                      onTap: () => context.go('/progress'),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person,
                      label: 'PROFILE',
                      isActive: index == 2,
                      onTap: () => context.go('/profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual navigation bar item.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 96;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: compact ? 24 : 28,
                  color: isActive ? c.primary : c.textSecondary,
                ),
                SizedBox(height: compact ? 3 : 4),
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.navLabel.copyWith(
                    color: isActive ? c.primary : c.textSecondary,
                    fontSize: compact ? 9 : 10,
                    letterSpacing: compact ? 0.8 : 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
