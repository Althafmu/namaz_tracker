import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_state.dart';
import 'widgets/streak_ring_painter.dart';
import 'widgets/monthly_calendar.dart';
import 'widgets/top_reasons.dart';
import 'widgets/badges_grid.dart';

/// Progress Room — functional version with live data and share.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
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
                      Text(
                        'Progress Room',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _shareProgress(context, state),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: c.border,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: c.border,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.share,
                            color: c.textPrimary,
                            size: 20,
                          ),
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
                          painter: StreakRingPainter(
                            prayers: state.prayers,
                            colors: c,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: c.streak,
                              size: 36,
                            ),
                            Text(
                              '${state.streak.currentStreak}',
                              style: AppTextStyles.streakNumber.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                            Text(
                              'DAY STREAK',
                              style: AppTextStyles.sectionHeader.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Monthly Calendar Heatmap ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: MonthlyCalendar(
                    historicalLog: state.historicalLog,
                    year: state.calendarYear,
                    month: state.calendarMonth,
                    bloc: context.read<PrayerBloc>(),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Top Reasons ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TopReasons(reasonCounts: state.reasonCounts),
                ),

                const SizedBox(height: 32),

                // ── Badges ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badges',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 20,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      BadgesGrid(state: state),
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
    message.writeln('🕌 Falah Prayer Tracker Progress');
    message.writeln('');
    message.writeln('🔥 Current Streak: $streak day${streak == 1 ? '' : 's'}');
    message.writeln('📅 This Week: $weeklyCount/35 prayers');
    message.writeln('✅ Today: $todayCount/5 prayers completed');
    message.writeln('');
    message.writeln('Keep up the consistency! 💪');

    SharePlus.instance.share(ShareParams(text: message.toString()));
  }
}
