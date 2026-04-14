import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../domain/entities/prayer.dart';
import '../../../bloc/streak/streak_state.dart';

/// Badges grid — dynamic based on user's real prayer data.
class BadgesGrid extends StatelessWidget {
  final List<Prayer> prayers;
  final StreakState streakState;

  const BadgesGrid({
    super.key,
    required this.prayers,
    required this.streakState,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    // Dynamic badge conditions
    final fajrDone = prayers.any(
      (p) => p.name.toLowerCase() == 'fajr' && p.isCompleted,
    );
    final anyJamaat = prayers.any((p) => p.inJamaat);
    final ishaDone = prayers.any(
      (p) => p.name.toLowerCase() == 'isha' && p.isCompleted,
    );
    final perfectMonth = streakState.streak.currentStreak >= 30;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        BadgeTile(
          icon: Icons.wb_sunny,
          title: 'Early Bird',
          baseColor: c.statusOnTime,
          isUnlocked: fajrDone,
        ),
        BadgeTile(
          icon: Icons.groups,
          title: 'Congregation\nCaptain',
          baseColor: c.jamaat,
          isUnlocked: anyJamaat,
        ),
        BadgeTile(
          icon: Icons.calendar_month,
          title: 'Perfect Month',
          baseColor: c.primary,
          isUnlocked: perfectMonth,
        ),
        BadgeTile(
          icon: Icons.nightlight,
          title: 'Night Owl',
          baseColor: c.statusNight,
          isUnlocked: ishaDone,
        ),
      ],
    );
  }
}

/// Individual badge tile — locked or unlocked appearance.
class BadgeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color baseColor;
  final bool isUnlocked;

  const BadgeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.baseColor,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return NeoCard(
      color: isUnlocked ? c.surface : c.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? baseColor.withValues(alpha: 0.15)
                    : c.textSecondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? baseColor.withValues(alpha: 0.3)
                      : c.borderPrimary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isUnlocked
                        ? baseColor
                        : c.textSecondary.withValues(alpha: 0.4),
                  ),
                  if (!isUnlocked)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: c.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.borderPrimary, width: 1),
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 10,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isUnlocked
                    ? c.textPrimary
                    : c.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
