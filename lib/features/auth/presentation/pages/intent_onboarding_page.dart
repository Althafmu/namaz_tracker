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
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose Your Path', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Select the approach that fits where you are right now. You can change this later.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _IntentCard(
                intent: IntentLevel.foundation,
                color: const Color(0xFF4CAF50),
                icon: Icons.grass,
                onTap: () => _selectIntent(context, IntentLevel.foundation),
              ),
              const SizedBox(height: 10),
              _IntentCard(
                intent: IntentLevel.strengthening,
                color: const Color(0xFFFF9800),
                icon: Icons.trending_up,
                onTap: () => _selectIntent(context, IntentLevel.strengthening),
              ),
              const SizedBox(height: 10),
              _IntentCard(
                intent: IntentLevel.growth,
                color: const Color(0xFF2196F3),
                icon: Icons.bolt,
                onTap: () => _selectIntent(context, IntentLevel.growth),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    GetIt.I<SettingsBloc>().add(
                      const UpdateIntentLevel('foundation'),
                    );
                    context.go('/');
                  },
                  child: Text(
                    'Not ready yet? Start Simple',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: c.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
    final c = AppColors.of(context);
    final highlights = switch (intent) {
      IntentLevel.foundation => const [
        'Gentle restart',
        'Full recovery options',
      ],
      IntentLevel.strengthening => const [
        'Priority recovery',
        'Stronger consistency focus',
      ],
      IntentLevel.growth => const [
        'Optional Sunnah tracker',
        'Most disciplined mode',
      ],
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.border, width: 3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: c.border, offset: const Offset(4, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  intent.displayName,
                  style: AppTextStyles.headlineSmall.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              intent.subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: highlights
                  .map(
                    (highlight) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: c.background,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: c.border, width: 2),
                      ),
                      child: Text(
                        highlight,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
