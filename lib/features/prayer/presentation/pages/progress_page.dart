import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_state.dart';

/// Progress Room — functional version with live data and share.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        final completedToday = state.completedCount;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress Room', style: AppTextStyles.headlineMedium),
                      GestureDetector(
                        onTap: () => _shareProgress(context, state),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.share, color: AppColors.textDark, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Hero Streak Ring ──
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: _StreakRingPainter(
                            progress: completedToday / 5.0,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: AppColors.streak,
                              size: 36,
                            ),
                            Text(
                              '${state.streak.currentStreak}',
                              style: AppTextStyles.streakNumber,
                            ),
                            Text(
                              'DAY STREAK',
                              style: AppTextStyles.sectionHeader,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Weekly Chart ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _WeeklyChart(
                    percentages: state.weeklyPercentages,
                    dayLabels: state.weeklyDayLabels,
                    totalPrayers: state.weeklyPrayerCount,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Badges ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Badges', style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                      const SizedBox(height: 16),
                      _BadgesGrid(state: state),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Bottom nav padding
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareProgress(BuildContext context, PrayerState state) {
    final streak = state.streak.currentStreak;
    final weeklyCount = state.weeklyPrayerCount;
    final todayCount = state.completedCount;

    final message = StringBuffer();
    message.writeln('🕌 Namaz Tracker Progress');
    message.writeln('');
    message.writeln('🔥 Current Streak: $streak day${streak == 1 ? '' : 's'}');
    message.writeln('📅 This Week: $weeklyCount/35 prayers');
    message.writeln('✅ Today: $todayCount/5 prayers completed');
    message.writeln('');
    message.writeln('Keep up the consistency! 💪');

    SharePlus.instance.share(
      ShareParams(text: message.toString()),
    );
  }
}

/// Custom painter for the circular streak ring.
class _StreakRingPainter extends CustomPainter {
  final double progress;
  _StreakRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 8.0;

    // Background ring
    final bgPaint = Paint()
      ..color = const Color(0xFFE2DADA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StreakRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Weekly bar chart — now driven by real data.
class _WeeklyChart extends StatelessWidget {
  final List<double> percentages;
  final List<String> dayLabels;
  final int totalPrayers;

  const _WeeklyChart({
    required this.percentages,
    required this.dayLabels,
    required this.totalPrayers,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This Week', style: AppTextStyles.bodyLarge),
              Text(
                '$totalPrayers/35 Prayers',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isToday = index == 6;
                final pct = percentages.length > index ? percentages[index] : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 2,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: pct.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? AppColors.streak
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabels.length > index ? dayLabels[index] : '',
                          style: AppTextStyles.badge.copyWith(
                            color: isToday
                                ? AppColors.textDark
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badges grid — dynamic based on user's real prayer data.
class _BadgesGrid extends StatelessWidget {
  final PrayerState state;

  const _BadgesGrid({required this.state});

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
        _BadgeTile(
          icon: Icons.wb_sunny,
          title: 'Early Bird',
          iconColor: AppColors.streak,
          bgColor: const Color(0xFFFEF9C3),
          isUnlocked: fajrDone,
        ),
        _BadgeTile(
          icon: Icons.groups,
          title: 'Congregation\nCaptain',
          iconColor: AppColors.jamaat,
          bgColor: const Color(0xFFCCFBF1),
          isUnlocked: anyJamaat,
        ),
        _BadgeTile(
          icon: Icons.calendar_month,
          title: 'Perfect Month',
          isUnlocked: perfectMonth,
          iconColor: AppColors.primary,
          bgColor: const Color(0xFFFFE4E6),
        ),
        _BadgeTile(
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

class _BadgeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? bgColor;
  final bool isUnlocked;

  const _BadgeTile({
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
