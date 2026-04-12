import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../domain/entities/prayer.dart';

/// Prayer card — teal when completed, white when pending.
class PrayerCard extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;

  const PrayerCard({super.key, required this.prayer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = prayer.isCompleted;

    return NeoCard(
      color: isCompleted ? AppColors.jamaat : AppColors.surface,
      onTap: onTap,
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prayer info
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name.toUpperCase(),
                    style: AppTextStyles.prayerTitle.copyWith(
                      color: isCompleted
                          ? AppColors.surface
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prayer.timeRange,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isCompleted
                          ? AppColors.surface.withValues(alpha: 0.9)
                          : AppColors.muted,
                    ),
                  ),
                  if (prayer.offset != null && prayer.offset != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Base: ${prayer.baseTime} ${prayer.offset! > 0 ? '+' : ''}${prayer.offset}m',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isCompleted
                              ? AppColors.surface.withValues(alpha: 0.7)
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              // Check button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? AppColors.jamaat : AppColors.muted,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
