import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../features/prayer/presentation/pages/home/home_page.dart';
import '../../features/prayer/presentation/pages/progress/progress_page.dart';
import '../../features/prayer/presentation/pages/profile/settings_page.dart';
import '../../features/prayer/presentation/pages/settings/notifications_settings_page.dart';
import '../../features/prayer/presentation/pages/settings/calculation_settings_page.dart';
import '../../features/prayer/presentation/pages/settings/reasons_settings_page.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding1_page.dart';
import '../../features/auth/presentation/pages/onboarding2_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/prayer/presentation/bloc/prayer/prayer_bloc.dart';
import '../../features/prayer/presentation/bloc/prayer/prayer_event.dart';
import '../../features/prayer/presentation/bloc/prayer/prayer_state.dart';

/// A [Listenable] that notifies when the [AuthBloc] state changes.
class AuthRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthRefreshListenable(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((state) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// App router using go_router with ShellRoute for bottom navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: AuthRefreshListenable(GetIt.I<AuthBloc>()),
  redirect: (context, state) {
    final authState = GetIt.I<AuthBloc>().state;
    final status = authState.status;
    final loggingIn = state.uri.path == '/login';
    final signingUp = state.uri.path == '/signup';
    final splash = state.uri.path == '/splash';
    final onboarding = state.uri.path.startsWith('/onboarding');

    // While loading or unknown, stay on splash (or current page)
    if (status == AuthStatus.unknown || status == AuthStatus.loading) {
      return null;
    }

    // If authenticated, don't allow login/signup/onboarding/splash
    if (status == AuthStatus.authenticated) {
      if (loggingIn || signingUp || onboarding || splash) {
        return '/';
      }
      return null;
    }

    // If unauthenticated, redirect to login unless on signup/onboarding/splash
    if (status == AuthStatus.unauthenticated) {
      if (loggingIn || signingUp || onboarding || splash) {
        return null;
      }
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding1',
      builder: (context, state) => const Onboarding1Page(),
    ),
    GoRoute(
      path: '/onboarding2',
      builder: (context, state) => const Onboarding2Page(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/progress',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProgressPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
        GoRoute(
          path: '/settings/notifications',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NotificationsSettingsPage(),
          ),
        ),
        GoRoute(
          path: '/settings/calculation',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CalculationSettingsPage(),
          ),
        ),
        GoRoute(
          path: '/settings/reasons',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ReasonsSettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

/// App shell with Neo-brutalist bottom navigation bar.
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/progress')) return 1;
    if (location.startsWith('/profile') || location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final index = _currentIndex(context);

    return Scaffold(
      backgroundColor: c.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(
            top: BorderSide(color: c.border, width: 2),
          ),
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
                _NavItem(
                  icon: Icons.home,
                  label: 'HOME',
                  isActive: index == 0,
                  onTap: () {
                    GetIt.I<PrayerBloc>().add(SelectDate(PrayerState.todayKey));
                    context.go('/');
                  },
                ),
                _NavItem(
                  icon: Icons.trending_up,
                  label: 'PROGRESS',
                  isActive: index == 1,
                  onTap: () => context.go('/progress'),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'PROFILE',
                  isActive: index == 2,
                  onTap: () => context.go('/profile'),
                ),
              ],
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
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? c.primary : c.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: isActive ? c.primary : c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
