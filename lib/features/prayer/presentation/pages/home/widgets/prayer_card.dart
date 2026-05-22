import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../../../core/services/status_helper.dart';
import '../../../../../../../core/services/time_service.dart';
import '../../../../domain/entities/prayer.dart';

Color _getPrayerColor(Prayer prayer, AppColorPalette c) {
  if (!prayer.isCompleted) return c.surface;
  if (prayer.status == 'missed') return c.statusMissed;
  if (prayer.status == 'late') return c.statusLate;
  if (prayer.status == 'qada') return c.statusQada;
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
      child: Container(
        constraints: BoxConstraints(minHeight: warningMessage != null ? 130 : 100),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      BouncyCheckIcon(
                        isCompleted: isCompleted,
                        isExcused: isExcused,
                        cardColor: cardColor,
                        c: c,
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
    
    String? warningMessage;
    Color? warningColor;
    Color? warningBackgroundColor;

    if (prayer.name == 'Jum\'ah' && !prayer.isCompleted && prayer.status != 'missed') {
      warningMessage = '"Whoever reads Surah Al-Kahf on Friday, he will be illuminated with light between the two Fridays."';
      warningColor = c.primary;
      warningBackgroundColor = c.primary.withValues(alpha: 0.1);
    }

    return _BasePrayerView(
      prayer: prayer,
      onTap: onTap,
      showTime: showTime,
      cardColor: _getPrayerColor(prayer, c),
      warningMessage: warningMessage,
      warningColor: warningColor,
      warningBackgroundColor: warningBackgroundColor,
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

    final remaining = recovery.expiresAt!.difference(TimeService.effectiveNow());
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
      warningMessage: StatusHelper.description('missed'),
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
      warningMessage: StatusHelper.tooltip('excused'),
      warningColor: c.textSecondary,
      warningBackgroundColor: c.border,
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

class BouncyCheckIcon extends StatefulWidget {
  final bool isCompleted;
  final bool isExcused;
  final Color cardColor;
  final AppColorPalette c;

  const BouncyCheckIcon({
    super.key,
    required this.isCompleted,
    required this.isExcused,
    required this.cardColor,
    required this.c,
  });

  @override
  State<BouncyCheckIcon> createState() => _BouncyCheckIconState();
}

class _BouncyCheckIconState extends State<BouncyCheckIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);

    if (widget.isCompleted) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant BouncyCheckIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _controller.forward(from: 0.0);
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      _controller.reverse(from: 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final isCompleted = widget.isCompleted;
    final isExcused = widget.isExcused;
    final cardColor = widget.cardColor;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCompleted
                ? (isExcused ? c.textSecondary : c.border)
                : c.border,
            width: 2,
          ),
          boxShadow: isCompleted
              ? null
              : [
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
          color: isCompleted
              ? (isExcused ? c.textSecondary : cardColor)
              : c.textSecondary,
          size: 30,
        ),
      ),
    );
  }
}
