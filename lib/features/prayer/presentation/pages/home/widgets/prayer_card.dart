import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../domain/entities/prayer.dart';

Color _getPrayerColor(Prayer prayer, AppColorPalette c) {
  if (!prayer.isCompleted) return c.surface;
  if (prayer.status == 'missed') return c.statusMissed;
  if (prayer.status == 'late') return c.statusLate;
  if (prayer.status == 'excused') return c.surface; // Keep it surface color to distinct from actual completion
  if (prayer.inJamaat) return c.statusGroup;
  return c.statusAlone;
}

/// Prayer card — router that delegates to one of 5 distinct sub-widgets.
/// Strict precedence: Excused > Expired > Recovery > Missed > Normal.
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

  @override
  Widget build(BuildContext context) {
    if (prayer.isExcused) {
      return ExcusedPrayerView(prayer: prayer, onTap: onTap, showTime: showTime);
    }

    final recovery = prayer.recoveryState;
    if (recovery != null && recovery.isExpired) {
      return ExpiredPrayerView(prayer: prayer, onTap: onTap, showTime: showTime);
    }

    if (prayer.isMissed && recovery != null && recovery.isProtected) {
      return RecoveryPrayerView(prayer: prayer, onTap: onTap, showTime: showTime);
    }

    if (prayer.isMissed) {
      return MissedPrayerView(prayer: prayer, onTap: onTap, showTime: showTime);
    }

    return NormalPrayerView(prayer: prayer, onTap: onTap, showTime: showTime);
  }
}

class _BasePrayerView extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final bool showTime;
  final Color cardColor;
  final Widget? customCheckIcon;
  final String? warningMessage;
  final Color? warningColor;
  final Color? warningBackgroundColor;

  const _BasePrayerView({
    required this.prayer,
    this.onTap,
    required this.showTime,
    required this.cardColor,
    this.customCheckIcon,
    this.warningMessage,
    this.warningColor,
    this.warningBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isCompleted = prayer.isCompleted;
    final isMissedCompletedCard = prayer.status == 'missed' && isCompleted;
    final isExcused = prayer.isExcused;
    // Use surface color text if card is solid filled (unless it's excused which holds surface background)
    final useLightText = isCompleted && !isMissedCompletedCard && !isExcused;

    return NeoCard(
      color: cardColor,
      onTap: onTap,
      child: SizedBox(
        height: warningMessage != null ? 130 : 100,
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
                          color: useLightText ? c.surface : c.textPrimary,
                        ),
                      ),
                      if (showTime) ...[
                        const SizedBox(height: 4),
                        Text(
                          prayer.timeRange,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: useLightText ? c.surface.withValues(alpha: 0.9) : c.textSecondary,
                          ),
                        ),
                        if (prayer.offset != null && prayer.offset != 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Base: ${prayer.baseTime} ${prayer.offset! > 0 ? '+' : ''}${prayer.offset}m',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: useLightText ? c.surface.withValues(alpha: 0.7) : c.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                  // Check button
                  customCheckIcon ??
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
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted ? (isExcused ? c.textSecondary : cardColor) : c.textSecondary,
                          size: 30,
                        ),
                      ),
                ],
              ),
              if (warningMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: warningBackgroundColor ?? Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    warningMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: warningColor ?? Colors.orange.shade800,
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

class NormalPrayerView extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final bool showTime;

  const NormalPrayerView({super.key, required this.prayer, this.onTap, required this.showTime});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _BasePrayerView(
      prayer: prayer,
      onTap: onTap,
      showTime: showTime,
      cardColor: _getPrayerColor(prayer, c),
    );
  }
}

class MissedPrayerView extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final bool showTime;

  const MissedPrayerView({super.key, required this.prayer, this.onTap, required this.showTime});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _BasePrayerView(
      prayer: prayer,
      onTap: onTap,
      showTime: showTime,
      cardColor: c.statusMissed,
      customCheckIcon: Container(
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
          Icons.close,
          color: c.statusMissed,
          size: 30,
        ),
      ),
    );
  }
}

class RecoveryPrayerView extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final bool showTime;

  const RecoveryPrayerView({super.key, required this.prayer, this.onTap, required this.showTime});

  String _getRecoveryMessage() {
    final recovery = prayer.recoveryState;
    if (recovery == null || recovery.expiresAt == null) return '';

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
    return _BasePrayerView(
      prayer: prayer,
      onTap: onTap,
      showTime: showTime,
      cardColor: _getPrayerColor(prayer, c), // usually surface if pending
      warningMessage: _getRecoveryMessage(),
      warningColor: Colors.orange.shade800,
      warningBackgroundColor: Colors.orange.withValues(alpha: 0.1),
    );
  }
}

class ExpiredPrayerView extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final bool showTime;

  const ExpiredPrayerView({super.key, required this.prayer, this.onTap, required this.showTime});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _BasePrayerView(
      prayer: prayer,
      onTap: onTap,
      showTime: showTime,
      cardColor: c.statusMissed,
      warningMessage: 'You needed to complete this prayer before the day ended',
      warningColor: Colors.red.shade800,
      warningBackgroundColor: Colors.red.withValues(alpha: 0.1),
      customCheckIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.border, width: 2),
        ),
        child: Icon(
          Icons.close,
          color: c.statusMissed,
          size: 30,
        ),
      ),
    );
  }
}

class ExcusedPrayerView extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final bool showTime;

  const ExcusedPrayerView({super.key, required this.prayer, this.onTap, required this.showTime});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return _BasePrayerView(
      prayer: prayer,
      onTap: onTap,
      showTime: showTime,
      cardColor: c.surface, // keeping it flat surface
      customCheckIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.border, width: 2),
        ),
        child: Icon(
          Icons.shield_outlined,
          color: c.textSecondary,
          size: 28,
        ),
      ),
    );
  }
}
