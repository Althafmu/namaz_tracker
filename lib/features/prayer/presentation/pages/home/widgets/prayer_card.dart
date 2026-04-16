import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../domain/entities/prayer.dart';

/// Prayer card — teal when completed, surface when pending.
/// Shows temporary streak protection warning for missed prayers within 24h window.
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

  String _getRecoveryMessage() {
    final recovery = prayer.recoveryState;
    if (recovery == null || !recovery.isProtected || recovery.expiresAt == null) {
      return '';
    }

    final remaining = recovery.expiresAt!.difference(DateTime.now());
    final hoursRemaining = remaining.inHours;

    if (hoursRemaining < 4) {
      return 'Complete this prayer soon to avoid losing your streak';
    } else if (hoursRemaining < 12) {
      return 'Complete this prayer today to keep your streak';
    } else {
      return 'Your streak is protected for now. Complete this prayer before the day ends to keep it.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isCompleted = prayer.isCompleted;
    final cardColor = _getPrayerColor(prayer, c);
    final recoveryMessage = _getRecoveryMessage();
    final showRecoveryWarning =
        prayer.isMissed && prayer.recoveryState?.isProtected == true && recoveryMessage.isNotEmpty;

    return NeoCard(
      color: isCompleted ? cardColor : c.surface,
      onTap: onTap,
      child: SizedBox(
        height: showRecoveryWarning ? 130 : 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
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
              if (showRecoveryWarning) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recoveryMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
