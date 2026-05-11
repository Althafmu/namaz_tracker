import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../data/models/group_dashboard_model.dart';

class CurrentUserCardWidget extends StatelessWidget {
  final CurrentUserStats stats;

  const CurrentUserCardWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return NeoCard(
      borderColor: c.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(
                  stats.currentStreak > 0 ? '${stats.currentStreak}' : '0',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  stats.currentStreak > 0 ? 'Day Streak' : 'Day Streak — Start today!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (stats.rank != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.primary, width: 1.5),
                ),
                child: Text(
                  'Rank #${stats.rank}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: c.primary,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              stats.role == 'ADMIN' ? 'Admin' : 'Member',
              style: AppTextStyles.bodySmall.copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}