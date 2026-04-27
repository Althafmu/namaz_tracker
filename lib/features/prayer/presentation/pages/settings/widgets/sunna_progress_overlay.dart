import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/settings/settings_state.dart';

class SunnaProgressOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const SunnaProgressOverlay({
    super.key,
    required this.onDismiss,
  });

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SunnaProgressOverlay(
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final settingsBloc = GetIt.I<SettingsBloc>();
    final state = settingsBloc.state;
    final intent = state.intentLevel;
    final streak = state.lastStreak;

    int daysToGrowth;
    String pathDescription;
    IconData pathIcon;
    Color pathColor;
    String nextLevelName;

    if (intent == IntentLevel.foundation) {
      daysToGrowth = (7 - streak).clamp(0, 7);
      pathDescription = 'You\'re on the Start Fresh path.';
      pathIcon = Icons.grass;
      pathColor = c.foundation;
      nextLevelName = 'Build Momentum';
    } else if (intent == IntentLevel.strengthening) {
      daysToGrowth = (21 - streak).clamp(0, 21);
      pathDescription = 'You\'re on the Build Momentum path.';
      pathIcon = Icons.trending_up;
      pathColor = c.strengthening;
      nextLevelName = 'Go All In';
    } else {
      daysToGrowth = 0;
      pathDescription = 'You\'re on the Go All In path.';
      pathIcon = Icons.bolt;
      pathColor = c.growth;
      nextLevelName = '';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: c.border, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sunna Tracker',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available in Growth mode',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: pathColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(pathIcon, color: pathColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Current Path',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pathDescription,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (intent != IntentLevel.growth) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: const Color(0xFF2196F3),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sunna Tracker is Locked',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF2196F3),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track optional Sunna prayers on your Home screen by upgrading to Growth mode.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: pathColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        daysToGrowth > 0
                            ? '$daysToGrowth days to unlock'
                            : 'Keep going!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: pathColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (intent == IntentLevel.growth)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sunna Tracker is available! Enable it in your settings.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          if (intent != IntentLevel.growth) ...[
            Center(
              child: Text(
                'Want to switch paths sooner?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onDismiss();
                  context.go('/intent-setup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Change My Path',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'You\'ll keep your streak and can switch back anytime.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
          if (intent == IntentLevel.growth)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Close',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}