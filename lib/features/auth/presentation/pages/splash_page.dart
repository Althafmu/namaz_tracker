import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../../prayer/presentation/bloc/settings/settings_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Delay initialization so the splash screen is visible for at least 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.read<AuthBloc>().add(InitAuthRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
