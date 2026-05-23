import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../../prayer/presentation/bloc/settings/settings_event.dart';
import '../../../prayer/presentation/bloc/settings/settings_state.dart';

class IntentOnboardingPage extends StatefulWidget {
  const IntentOnboardingPage({super.key});

  @override
  State<IntentOnboardingPage> createState() => _IntentOnboardingPageState();
}

class _IntentOnboardingPageState extends State<IntentOnboardingPage> {
  bool _showExplanation = true;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final settingsBloc = GetIt.I<SettingsBloc>();
    final currentIntent = settingsBloc.state.intentLevel;
    final currentStreak = settingsBloc.state.lastStreak;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canPop) ...[
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: c.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Choose Your Path',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick the approach that fits where you are right now. You can always change this later.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _IntentCard(
                    intent: IntentLevel.foundation,
                    color: c.foundation,
                    icon: Icons.grass,
                    onTap: () => _selectIntent(context, IntentLevel.foundation),
                    currentStreak: currentStreak,
                  ),
                  const SizedBox(height: 10),
                  _IntentCard(
                    intent: IntentLevel.strengthening,
                    color: c.strengthening,
                    icon: Icons.trending_up,
                    onTap: () => _selectIntent(context, IntentLevel.strengthening),
                    currentStreak: currentStreak,
                  ),
                  const SizedBox(height: 10),
                  _IntentCard(
                    intent: IntentLevel.growth,
                    color: c.growth,
                    icon: Icons.bolt,
                    onTap: () => _selectIntent(context, IntentLevel.growth),
                    currentStreak: currentStreak,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (canPop) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/');
                        }
                      },
                      child: Text(
                        'Not ready? Just continue with your current path.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: c.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (_showExplanation) ...[
                    const SizedBox(height: 24),
                    _PathExplanationSheet(
                      currentIntent: currentIntent,
                      currentStreak: currentStreak,
                      onClose: () {
                        setState(() {
                          _showExplanation = false;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectIntent(BuildContext context, IntentLevel intent) {
    GetIt.I<SettingsBloc>().add(UpdateIntentLevel(intent.name));
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }
}

class _PathExplanationSheet extends StatelessWidget {
  final IntentLevel currentIntent;
  final int currentStreak;
  final VoidCallback onClose;

  const _PathExplanationSheet({
    required this.currentIntent,
    required this.currentStreak,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    int nextThreshold;

    if (currentIntent == IntentLevel.foundation) {
      nextThreshold = 7;
    } else if (currentIntent == IntentLevel.strengthening) {
      nextThreshold = 21;
    } else {
      nextThreshold = 0;
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: c.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'How Path Upgrading Works',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: c.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: c.textSecondary, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPathRow(
              c,
              icon: Icons.grass,
              color: c.foundation,
              title: 'Start Fresh',
              subtitle: 'Missed prayers? No problem — make up any prayer easily.',
              badge: 'Foundation',
            ),
            const SizedBox(height: 8),
            _buildPathRow(
              c,
              icon: Icons.trending_up,
              color: c.strengthening,
              title: 'Build Momentum',
              subtitle: 'Focus on staying consistent. Fajr recovery is prioritized.',
              badge: 'Strengthening',
            ),
            const SizedBox(height: 8),
            _buildPathRow(
              c,
              icon: Icons.bolt,
              color: c.growth,
              title: 'Go All In',
              subtitle: 'Full tracking + optional Sunna prayers shown on Home.',
              badge: 'Growth',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.upgrade, color: c.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentIntent == IntentLevel.growth
                          ? 'You\'re at the highest level! Sunna tracking is available.'
                          : 'Upgrade automatically after $nextThreshold days of consistency.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathRow(
    AppColorPalette c, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IntentCard extends StatelessWidget {
  final IntentLevel intent;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final int currentStreak;

  const _IntentCard({
    required this.intent,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final cardContent = switch (intent) {
      IntentLevel.foundation => _CardContent(
          title: 'Start Fresh',
          subtitle: 'You\'re beginning or restarting. Go at your own pace — missed prayers can be made up easily anytime.',
          highlights: const ['Easy recovery', 'Gentle reminders'],
          color: color,
          icon: icon,
          badge: 'Foundation',
          badgeColor: color,
        ),
      IntentLevel.strengthening => _CardContent(
          title: 'Build Momentum',
          subtitle: 'You\'re staying consistent but still slip up sometimes. Focus on maintaining your streak.',
          highlights: const ['Priority recovery', 'Steady focus'],
          color: color,
          icon: icon,
          badge: 'Strengthening',
          badgeColor: color,
        ),
      IntentLevel.growth => _CardContent(
          title: 'Go All In',
          subtitle: 'You\'re disciplined and want full tracking. Sunna prayers appear on your Home screen.',
          highlights: const ['Sunna tracker', 'Full discipline'],
          color: color,
          icon: icon,
          badge: 'Growth',
          badgeColor: color,
        ),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardContent.title,
                        style: AppTextStyles.headlineSmall.copyWith(color: color),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cardContent.badge,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              cardContent.subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cardContent.highlights
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

class _CardContent {
  final String title;
  final String subtitle;
  final List<String> highlights;
  final Color color;
  final IconData icon;
  final String badge;
  final Color badgeColor;

  const _CardContent({
    required this.title,
    required this.subtitle,
    required this.highlights,
    required this.color,
    required this.icon,
    required this.badge,
    required this.badgeColor,
  });
}