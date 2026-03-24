import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../domain/entities/prayer.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_state.dart';
import 'prayer_logger_sheet.dart';

/// Dashboard / Home Page — matches dashboard.html Stitch mockup.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                // ── Streak Header ──
                _StreakHeader(streak: state.streak.currentStreak),

                const SizedBox(height: 24),

                // ── Prayer List ──
                Expanded(
                  child: ListView.builder(
                    itemCount: state.prayers.length + 1, // +1 for quote
                    itemBuilder: (context, index) {
                      // Insert motivational quote after Maghrib (index 3)
                      if (index == 4) {
                        return _MotivationalBanner();
                      }
                      final prayerIndex = index > 4 ? index - 1 : index;
                      if (prayerIndex >= state.prayers.length) return null;
                      final prayer = state.prayers[prayerIndex];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PrayerCard(
                          prayer: prayer,
                          onTap: () => _showPrayerLogger(context, prayer),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrayerLogger(BuildContext context, Prayer prayer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PrayerBloc>(),
        child: PrayerLoggerSheet(prayer: prayer),
      ),
    );
  }
}

/// Yellow streak banner: "12 Day Streak!"
class _StreakHeader extends StatelessWidget {
  final int streak;
  const _StreakHeader({required this.streak});

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
              style: AppTextStyles.headlineMedium.copyWith(
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prayer card — teal when completed, white when pending.
class _PrayerCard extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;

  const _PrayerCard({required this.prayer, this.onTap});

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
                      color: isCompleted ? AppColors.surface : AppColors.textDark,
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
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
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

/// Motivational quote banner.
class _MotivationalBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeoCard(
        color: AppColors.backgroundLight,
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u201C\u201C',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'The first matter that the slave will be brought to account for on the Day of Judgment is the prayer.',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
