import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';

/// Yellow streak banner: "12 Day Streak!"
class StreakHeader extends StatelessWidget {
  final int streak;
  const StreakHeader({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.streak,
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: AppColors.primary,
              size: 36,
            ),
            const SizedBox(width: 12),
            Text(
              '$streak Day Streak!',
              style: AppTextStyles.headlineMedium.copyWith(letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
