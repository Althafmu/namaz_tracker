import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/services/status_helper.dart';
import '../../../../../core/services/time_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_card.dart';
import '../../../domain/entities/prayer.dart';
import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_state.dart';
import '../../bloc/history/history_bloc.dart';
import '../../bloc/history/history_state.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/stats/stats_bloc.dart';
import '../../bloc/stats/stats_state.dart';
import '../../bloc/streak/streak_bloc.dart';
import '../../bloc/streak/streak_state.dart';
import 'widgets/monthly_calendar.dart';
import 'widgets/top_reasons.dart';
import 'widgets/badges_grid.dart';
import 'widgets/radar_chart.dart';
import 'widgets/sync_metadata_card.dart';
import 'widgets/weekly_chart.dart';

/// Progress Room — functional version with live data and share.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final settingsState = context.watch<SettingsBloc>().state;

    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, prayerState) {
        return BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, historyState) {
            return BlocBuilder<StatsBloc, StatsState>(
              builder: (context, statsState) {
                return BlocBuilder<StreakBloc, StreakState>(
                  builder: (context, streakState) {
                    // Show loading state while prayers are being fetched
                    if (prayerState.isLoading && prayerState.prayers.isEmpty) {
                      return SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: c.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Loading your progress...',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final todayCount = prayerState.prayers
                        .where((p) => p.isCompleted && !p.isExcused)
                        .length;
                    final weeklyCount = historyState.weeklyPrayerCount;
                    final weeklyPercent = ((weeklyCount / 35) * 100).round();
                    final mergedHistoricalLog = _mergeTodayIntoHistory(
                      historyState.historicalLog,
                      prayerState.prayers,
                    );
                    final qadaAnalytics = _buildQadaAnalytics(
                      mergedHistoricalLog,
                      prayerState.prayers,
                    );

                    // Total lifetime prayers logged
                    final totalLogged = mergedHistoricalLog.values
                        .fold<int>(
                          0,
                          (sum, prayers) =>
                              sum +
                              prayers
                                  .where((p) => p.isCompleted && !p.isExcused)
                                  .length,
                        );
                    // Total days with at least one prayer
                      final totalDays = mergedHistoricalLog.entries
                        .where(
                          (e) =>
                              e.value.any((p) => p.isCompleted && !p.isExcused),
                        )
                        .length;

                    return SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header ──
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Your Progress',
                                    style: AppTextStyles.headlineMedium
                                        .copyWith(color: c.textPrimary),
                                  ),
                                  GestureDetector(
                                    onTap: () => _shareProgress(
                                      context,
                                      streakState,
                                      historyState,
                                      prayerState,
                                    ),
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

                            const SizedBox(height: 20),

                            // ── Summary Stats Row ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickStat(
                                      context,
                                      label: 'Today',
                                      value: '$todayCount/5',
                                      icon: Icons.today,
                                      iconColor: c.jamaat,
                                      iconBg: c.jamaatLight,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickStat(
                                      context,
                                      label: '7 Days',
                                      value: '$weeklyCount/35',
                                      icon: Icons.calendar_view_week,
                                      iconColor: c.primary,
                                      iconBg: c.primaryLight,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickStat(
                                      context,
                                      label: 'Rate',
                                      value: '$weeklyPercent%',
                                      icon: Icons.insights,
                                      iconColor: c.streak,
                                      iconBg: c.streakLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Lifetime stats row ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickStat(
                                      context,
                                      label: 'Total Logged',
                                      value: '$totalLogged',
                                      icon: Icons.check_circle_outline,
                                      iconColor: c.success,
                                      iconBg: c.jamaatLight,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickStat(
                                      context,
                                      label: 'Days Tracked',
                                      value: '$totalDays',
                                      icon: Icons.calendar_today,
                                      iconColor: c.primary,
                                      iconBg: c.primaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            if (settingsState.qadaTrackingEnabled) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: _buildQadaAnalyticsCard(
                                  context,
                                  qadaAnalytics,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // ── Streak Cards ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: _buildStreakCards(
                                context,
                                c,
                                streakState,
                                historyState,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Weekly Bar Chart ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: WeeklyChart(
                                percentages: historyState.weeklyPercentages,
                                dayLabels: historyState.weeklyDayLabels,
                                totalPrayers: weeklyCount,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Sync Metadata ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: SyncMetadataCard(
                                syncStatus: prayerState.syncStatus,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Monthly Calendar Heatmap ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: historyState.historicalLog.isEmpty
                                  ? NeoCard(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            size: 40,
                                            color: c.textSecondary.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Your monthly heatmap will show up once you start tracking prayers.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: c.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : MonthlyCalendar(
                                      historicalLog: historyState.historicalLog,
                                      year: historyState.calendarYear,
                                      month: historyState.calendarMonth,
                                      bloc: context.read<HistoryBloc>(),
                                    ),
                            ),

                            const SizedBox(height: 20),

                            // ── Radar Chart ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: historyState.historicalLog.isEmpty
                                  ? NeoCard(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.radar_outlined,
                                            size: 40,
                                            color: c.textSecondary.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Prayer distribution will appear here after you log a few days.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: c.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : PrayerRadarChart(
                                      historicalLog: historyState.historicalLog,
                                      colors: c,
                                    ),
                            ),

                            const SizedBox(height: 20),

                            // ── Top Reasons ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TopReasons(
                                reasonCounts: statsState.reasonCounts,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── Badges ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Badges',
                                    style: AppTextStyles.headlineMedium
                                        .copyWith(
                                          fontSize: 20,
                                          color: c.textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  BadgesGrid(
                                    prayers: prayerState.prayers,
                                    streakState: streakState,
                                  ),
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
              },
            );
          },
        );
      },
    );
  }

  /// Streak cards: Daily Streak (orange) + Best Streak (green) with weekly dots.
  Widget _buildStreakCards(
    BuildContext context,
    AppColorPalette c,
    StreakState streakState,
    HistoryState historyState,
  ) {
    final streak = streakState.streak.displayStreak;
    final best = streakState.streak.longestStreak;

    // Weekly dots: last 7 days (Mon-Sun or similar)
    final effectiveNow = TimeService.effectiveNow();
    final weekDots = List.generate(7, (i) {
      final date = effectiveNow.subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final prayers = historyState.historicalLog[key] ?? [];
      final completed = prayers
          .where((p) => p.isCompleted && !p.isExcused)
          .length;
      return completed >= 5; // full day = all 5 prayers done
    });
    final weekLabels = List.generate(7, (i) {
      final date = effectiveNow.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date).substring(0, 1);
    });

    return Row(
      children: [
        // Daily streak card
        Expanded(
          child: NeoCard(
            color: c.streakLight,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: c.streak,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daily Streak',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$streak',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: c.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                // Weekly dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    return Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: weekDots[i]
                                ? c.streak
                                : c.border.withValues(alpha: 0.2),
                            border: Border.all(
                              color: weekDots[i]
                                  ? c.streak
                                  : c.border.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          weekLabels[i],
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 9,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Best streak card
        Expanded(
          child: NeoCard(
            color: c.jamaatLight,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: c.jamaat, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Best Streak',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$best',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: c.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  best > 0
                      ? 'Personal best achieved 🏆'
                      : 'Start your streak today!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQadaAnalyticsCard(
    BuildContext context,
    _QadaAnalytics analytics,
  ) {
    final c = AppColors.of(context);

    return NeoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.statusQada.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_late_outlined,
                  color: c.statusQada,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qada Recovery',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      analytics.lifetimeCount > 0
                          ? 'Make-up prayers are counted separately so recovery stays visible.'
                          : 'This section will start filling in once you log your first Qada prayer.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  context,
                  label: 'Today',
                  value: '${analytics.todayCount}',
                  icon: Icons.today,
                  iconColor: c.statusQada,
                  iconBg: c.statusQada.withValues(alpha: 0.14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  context,
                  label: '7 Days',
                  value: '${analytics.weeklyCount}',
                  icon: Icons.calendar_view_week,
                  iconColor: c.statusQada,
                  iconBg: c.statusQada.withValues(alpha: 0.14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  context,
                  label: 'Lifetime',
                  value: '${analytics.lifetimeCount}',
                  icon: Icons.analytics_outlined,
                  iconColor: c.statusQada,
                  iconBg: c.statusQada.withValues(alpha: 0.14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStat(
                  context,
                  label: 'Open Recovery',
                  value: '${analytics.openRecoveryCount}',
                  icon: Icons.refresh,
                  iconColor: c.streak,
                  iconBg: c.streakLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            analytics.topPrayerName != null
                ? 'Most common Qada prayer: ${analytics.topPrayerName}'
                : 'Most common Qada prayer: none yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            StatusHelper.description('qada'),
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Prayer>> _mergeTodayIntoHistory(
    Map<String, List<Prayer>> historicalLog,
    List<Prayer> todayPrayers,
  ) {
    final merged = Map<String, List<Prayer>>.from(historicalLog);
    if (todayPrayers.isEmpty) {
      return merged;
    }

    final todayKey = DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());
    merged[todayKey] = todayPrayers;
    return merged;
  }

  _QadaAnalytics _buildQadaAnalytics(
    Map<String, List<Prayer>> historicalLog,
    List<Prayer> todayPrayers,
  ) {
    final todayKey = DateFormat('yyyy-MM-dd').format(TimeService.effectiveNow());
    final todayCount = (historicalLog[todayKey] ?? todayPrayers)
        .where((p) => p.isQada)
        .length;

    int weeklyCount = 0;
    int lifetimeCount = 0;
    final prayerCounts = <String, int>{};

    for (final entry in historicalLog.entries) {
      final date = DateTime.tryParse(entry.key);
      final qadaForDay = entry.value.where((p) => p.isQada).toList();

      lifetimeCount += qadaForDay.length;
      for (final prayer in qadaForDay) {
        prayerCounts.update(prayer.name, (count) => count + 1, ifAbsent: () => 1);
      }

      if (date == null) {
        continue;
      }

      final dayDifference = TimeService.effectiveNow().difference(date).inDays;
      if (dayDifference >= 0 && dayDifference < 7) {
        weeklyCount += qadaForDay.length;
      }
    }

    final openRecoveryCount = todayPrayers.where((p) {
      final recovery = p.recoveryState;
      return recovery != null &&
          recovery.requiresQada &&
          !recovery.isExpired &&
          !p.isQada &&
          !p.isExcused;
    }).length;

    String? topPrayerName;
    int topPrayerCount = 0;
    for (final entry in prayerCounts.entries) {
      if (entry.value > topPrayerCount) {
        topPrayerCount = entry.value;
        topPrayerName = entry.key;
      }
    }

    return _QadaAnalytics(
      todayCount: todayCount,
      weeklyCount: weeklyCount,
      lifetimeCount: lifetimeCount,
      openRecoveryCount: openRecoveryCount,
      topPrayerName: topPrayerName,
    );
  }

  void _shareProgress(
    BuildContext context,
    StreakState streakState,
    HistoryState historyState,
    PrayerState prayerState,
  ) {
    final streak = streakState.streak.displayStreak;
    final weeklyCount = historyState.weeklyPrayerCount;
    final todayCount = prayerState.prayers
        .where((p) => p.isCompleted && !p.isExcused)
        .length;

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

  Widget _buildQuickStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyLarge.copyWith(
              color: c.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QadaAnalytics {
  final int todayCount;
  final int weeklyCount;
  final int lifetimeCount;
  final int openRecoveryCount;
  final String? topPrayerName;

  const _QadaAnalytics({
    required this.todayCount,
    required this.weeklyCount,
    required this.lifetimeCount,
    required this.openRecoveryCount,
    required this.topPrayerName,
  });
}
