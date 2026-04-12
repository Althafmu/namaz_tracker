import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../bloc/prayer/prayer_state.dart';

/// Badges grid — dynamic based on user's real prayer data.
class BadgesGrid extends StatelessWidget {
  final PrayerState state;

  const BadgesGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Dynamic badge conditions
    final fajrDone = state.prayers.any(
      (p) => p.name.toLowerCase() == 'fajr' && p.isCompleted,
    );
    final anyJamaat = state.prayers.any((p) => p.inJamaat);
    final ishaDone = state.prayers.any(
      (p) => p.name.toLowerCase() == 'isha' && p.isCompleted,
    );
    final perfectMonth = state.streak.currentStreak >= 30;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        BadgeTile(
          icon: Icons.wb_sunny,
          title: 'Early Bird',
          iconColor: AppColors.streak,
          bgColor: const Color(0xFFFEF9C3),
          isUnlocked: fajrDone,
        ),
        BadgeTile(
          icon: Icons.groups,
          title: 'Congregation\nCaptain',
          iconColor: AppColors.jamaat,
          bgColor: const Color(0xFFCCFBF1),
          isUnlocked: anyJamaat,
        ),
        BadgeTile(
          icon: Icons.calendar_month,
          title: 'Perfect Month',
          isUnlocked: perfectMonth,
          iconColor: AppColors.primary,
          bgColor: const Color(0xFFFFE4E6),
        ),
        BadgeTile(
          icon: Icons.nightlight,
          title: 'Night Owl',
          isUnlocked: ishaDone,
          iconColor: const Color(0xFF6366F1),
          bgColor: const Color(0xFFE0E7FF),
        ),
      ],
    );
  }
}

/// Individual badge tile — locked or unlocked appearance.
class BadgeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? bgColor;
  final bool isUnlocked;

  const BadgeTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.bgColor,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUnlocked) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF9CA3AF), width: 2),
        ),
        child: Opacity(
          opacity: 0.6,
          child: Stack(
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.lock, color: Colors.grey[500], size: 16),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 36, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
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

    return NeoCard(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: bgColor ?? Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
