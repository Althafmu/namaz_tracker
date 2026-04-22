import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _showLoading = false;
  bool _timedOut = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Delay initialization so the splash screen is visible for at least 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showLoading = true);
        final status = context.read<AuthBloc>().state.status;
        if (status == AuthStatus.unknown) {
          context.read<AuthBloc>().add(InitAuthRequested());
          // Timeout fallback: if auth check hangs for 10s, show retry
          _timeoutTimer = Timer(const Duration(seconds: 10), () {
            if (mounted &&
                context.read<AuthBloc>().state.status == AuthStatus.unknown) {
              setState(() => _timedOut = true);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _timedOut = false;
      _showLoading = true;
    });
    context.read<AuthBloc>().add(InitAuthRequested());
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted &&
          context.read<AuthBloc>().state.status == AuthStatus.unknown) {
        setState(() => _timedOut = true);
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
            Icon(
              Icons.nightlight_round,
              size: 120,
              color: AppColors.of(context).primary,
            ),
            const SizedBox(height: 24),
            Text('Falah', style: AppTextStyles.headlineLarge),
            Text('Prayer Tracker', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 32),
            if (_timedOut) ...[
              Text(
                'Taking longer than expected...',
                style: TextStyle(
                  color: AppColors.of(context).textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ] else if (_showLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.of(context).primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
