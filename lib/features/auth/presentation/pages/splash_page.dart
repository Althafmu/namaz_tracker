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
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(InitAuthRequested());

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      if (authState.status == AuthStatus.authenticated) {
        context.go('/');
      } else if (authState.hasSeenOnboarding) {
        context.go('/login');
      } else {
        context.go('/onboarding1');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a simple icon for the moon in Splash, or text if needed.
            // As per stitch, it's a big moon icon. We use Icons.nightlight_round
            Icon(Icons.nightlight_round, size: 120, color: AppColors.primary),
            SizedBox(height: 24),
            Text('NAMAZ', style: AppTextStyles.headlineLarge),
            Text('TRACKER', style: AppTextStyles.headlineMedium),
          ],
        ),
      ),
    );
  }
}
