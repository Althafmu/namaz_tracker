import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../../prayer/presentation/bloc/settings/settings_event.dart';
import '../../../prayer/presentation/bloc/settings/settings_state.dart';

class IntentOnboardingPage extends StatelessWidget {
  const IntentOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Choose Your Path',
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select the approach that fits where you are right now.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _IntentCard(
                  intent: IntentLevel.foundation,
                  color: const Color(0xFF4CAF50),
                  icon: Icons.grass,
                  onTap: () => _selectIntent(context, IntentLevel.foundation),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _IntentCard(
                  intent: IntentLevel.strengthening,
                  color: const Color(0xFFFF9800),
                  icon: Icons.trending_up,
                  onTap: () => _selectIntent(context, IntentLevel.strengthening),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _IntentCard(
                  intent: IntentLevel.growth,
                  color: const Color(0xFF2196F3),
                  icon: Icons.bolt,
                  onTap: () => _selectIntent(context, IntentLevel.growth),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    GetIt.I<SettingsBloc>().add(const UpdateIntentLevel('foundation'));
                    context.go('/');
                  },
                  child: Text(
                    'Not ready yet? Start Simple',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.of(context).primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _selectIntent(BuildContext context, IntentLevel intent) {
    GetIt.I<SettingsBloc>().add(UpdateIntentLevel(intent.name));
    context.go('/');
  }
}

class _IntentCard extends StatelessWidget {
  final IntentLevel intent;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _IntentCard({
    required this.intent,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          border: Border.all(color: AppColors.of(context).border, width: 3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).border,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const Spacer(),
            Text(
              intent.displayName,
              style: AppTextStyles.headlineMedium.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              intent.subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.of(context).textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}