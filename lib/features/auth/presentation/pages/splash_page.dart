import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(InitAuthRequested());

    // Safety fallback: if auth never resolves within 5 seconds,
    // force navigation to login to avoid black screen forever.
    Future.delayed(const Duration(seconds: 5), () {
      _navigateIfNeeded();
    });
  }

  void _navigateIfNeeded() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated) {
      context.go('/');
    } else if (authState.hasSeenOnboarding) {
      context.go('/login');
    } else {
      context.go('/onboarding1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr.status == AuthStatus.authenticated ||
          curr.status == AuthStatus.unauthenticated,
      listener: (context, state) {
        // Wait a minimum 1.5s so the splash is visible, then navigate
        Future.delayed(const Duration(milliseconds: 1500), () {
          _navigateIfNeeded();
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nightlight_round, size: 120, color: AppColors.of(context).primary),
              const SizedBox(height: 24),
              Text('NAMAZ', style: AppTextStyles.headlineLarge),
              Text('TRACKER', style: AppTextStyles.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}
