import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_card.dart';
import '../../bloc/history/history_bloc.dart';
import '../../bloc/history/history_state.dart';
import '../../bloc/streak/streak_bloc.dart';
import '../../bloc/streak/streak_state.dart';
import '../progress/widgets/monthly_calendar.dart';

/// Full-screen Streak Detail Page.
/// Accessible by tapping the streak badge on the home page.
class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<StreakBloc, StreakState>(
      bloc: GetIt.I<StreakBloc>(),
      builder: (context, streakState) {
        return BlocBuilder<HistoryBloc, HistoryState>(
          bloc: GetIt.I<HistoryBloc>(),
          builder: (context, historyState) {
            final streak = streakState.streak.displayStreak;
            final best = streakState.streak.longestStreak;

            return Scaffold(
              backgroundColor: c.background,
              appBar: AppBar(
                backgroundColor: c.background,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.border, width: 2),
                    ),
                    child: Icon(Icons.close, color: c.textPrimary, size: 20),
                  ),
                ),
                title: Text(
                  'Streak',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ── Hero: fire icon + big streak number ──
                      _buildHeroSection(context, c, streak),

                      const SizedBox(height: 32),

                      // ── Next Milestone ──
                      _buildMilestoneSection(context, c, streak),

                      const SizedBox(height: 24),

                      // ── Best Streak chip ──
                      _buildBestStreakRow(context, c, streak, best),

                      const SizedBox(height: 24),

                      // ── Monthly Calendar ──
                      MonthlyCalendar(
                        historicalLog: historyState.historicalLog,
                        year: historyState.calendarYear,
                        month: historyState.calendarMonth,
                        bloc: GetIt.I<HistoryBloc>(),
                      ),

                      const SizedBox(height: 32),

                      // ── Share Streak button ──
                      _buildShareButton(context, c, streak, best),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroSection(BuildContext context, AppColorPalette c, int streak) {
    return NeoCard(
      color: c.streak,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.local_fire_department,
              color: c.onAccent,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              '$streak',
              style: AppTextStyles.streakNumber.copyWith(
                fontSize: 80,
                color: c.onAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Day Streak',
              style: AppTextStyles.headlineMedium.copyWith(
                color: c.onAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete all 5 daily prayers to build your streak.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.onAccent.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneSection(BuildContext context, AppColorPalette c, int streak) {
    // Determine next milestone
    final milestones = [7, 14, 30, 60, 100, 200, 365];
    int nextMilestone = milestones.firstWhere(
      (m) => m > streak,
      orElse: () => streak + 100,
    );
    final prevMilestone = milestones
        .where((m) => m <= streak)
        .fold(0, (prev, m) => m > prev ? m : prev);

    final progress = nextMilestone > prevMilestone
        ? (streak - prevMilestone) / (nextMilestone - prevMilestone)
        : 1.0;
    final daysToGo = nextMilestone - streak;

    return NeoCard(
      color: c.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Milestone',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: c.streak.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.streak, width: 1.5),
                ),
                child: Text(
                  '$nextMilestone days 🎯',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: c.border.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(c.streak),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            daysToGo > 0
                ? '$daysToGo day${daysToGo == 1 ? '' : 's'} to go'
                : 'Milestone reached! 🎉',
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestStreakRow(
    BuildContext context,
    AppColorPalette c,
    int streak,
    int best,
  ) {
    return Row(
      children: [
        Expanded(
          child: NeoCard(
            color: c.streakLight,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Icon(Icons.local_fire_department, color: c.streak, size: 28),
                const SizedBox(height: 6),
                Text(
                  '$streak',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Current',
                  style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeoCard(
            color: c.jamaatLight,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Icon(Icons.emoji_events, color: c.jamaat, size: 28),
                const SizedBox(height: 6),
                Text(
                  '$best',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Best',
                  style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    AppColorPalette c,
    int streak,
    int best,
  ) {
    return GestureDetector(
      onTap: () => _shareStreak(streak, best),
      child: NeoCard(
        color: c.primary,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, color: c.onAccent, size: 22),
            const SizedBox(width: 10),
            Text(
              'Share Streak',
              style: AppTextStyles.bodyLarge.copyWith(
                color: c.onAccent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareStreak(int streak, int best) {
    final message = StringBuffer();
    message.writeln('🕌 Falah Prayer Tracker');
    message.writeln('');
    message.writeln('🔥 Current Streak: $streak day${streak == 1 ? '' : 's'}');
    message.writeln('🏆 Best Streak: $best day${best == 1 ? '' : 's'}');
    message.writeln('');
    message.writeln('Stay consistent and keep the streak alive! 💪');
    SharePlus.instance.share(ShareParams(text: message.toString()));
  }
}
