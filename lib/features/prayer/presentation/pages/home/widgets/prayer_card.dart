import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../domain/entities/prayer.dart';

/// Prayer card — teal when completed, surface when pending.
class PrayerCard extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final bool showTime;

  const PrayerCard({
    super.key,
    required this.prayer,
    this.onTap,
    this.showTime = true,
  });

  Color _getPrayerColor(Prayer prayer, AppColorPalette c) {
    if (!prayer.isCompleted) return c.surface;
    if (prayer.status == 'missed') return c.statusMissed;
    if (prayer.status == 'late') return c.statusLate;
    if (prayer.inJamaat) return c.statusGroup;
    return c.statusAlone;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isCompleted = prayer.isCompleted;
    final cardColor = _getPrayerColor(prayer, c);

    return NeoCard(
      color: isCompleted ? cardColor : c.surface,
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
                          ? c.surface
                          : c.textPrimary,
                    ),
                  ),
                  if (showTime) ...[
                    const SizedBox(height: 4),
                    Text(
                      prayer.timeRange,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isCompleted
                            ? c.surface.withValues(alpha: 0.9)
                            : c.textSecondary,
                      ),
                    ),
                    if (prayer.offset != null && prayer.offset != 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Base: ${prayer.baseTime} ${prayer.offset! > 0 ? '+' : ''}${prayer.offset}m',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isCompleted
                                ? c.surface.withValues(alpha: 0.7)
                                : c.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              // Check button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: c.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: c.border,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? cardColor : c.textSecondary,
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
