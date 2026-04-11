import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';

import '../../domain/entities/prayer.dart';

/// Progress Room — functional version with live data and share.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        style: AppTextStyles.headlineMedium,
                      ),
                      GestureDetector(
                        onTap: () => _shareProgress(context, state),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.share,
                            color: AppColors.textDark,
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
                          painter: _StreakRingPainter(prayers: state.prayers),
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

                // ── Weekly Chart (Commented out per request) ──
                /*
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _WeeklyChart(
                    percentages: state.weeklyPercentages,
                    dayLabels: state.weeklyDayLabels,
                    totalPrayers: state.weeklyPrayerCount,
                  ),
                ),
                */
                // const SizedBox(height: 24),

                // ── Contribution Heatmap (Commented out per request) ──
                /*
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ContributionMap(history: state.weeklyHistory),
                ),
                */
                // const SizedBox(height: 32),

                // ── Monthly Calendar Heatmap ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _MonthlyCalendar(
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
                  child: _TopReasons(reasonCounts: state.reasonCounts),
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
                        ),
                      ),
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

    SharePlus.instance.share(ShareParams(text: message.toString()));
  }
}

class _StreakRingPainter extends CustomPainter {
  final List<Prayer> prayers;
  final double strokeWidth;
  final double gapAngle;

  _StreakRingPainter({
    required this.prayers,
    this.strokeWidth = 8.0,
    this.gapAngle = 0.08,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prayers.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth - 2;

    final totalSegments = prayers.length;

    // If only one prayer, draw a full circle without gaps
    if (totalSegments == 1) {
      final prayer = prayers.first;
      Color segmentColor = AppColors.statusNotLogged;

      if (prayer.isCompleted) {
        if (prayer.status == 'late') {
          segmentColor = AppColors.statusLate;
        } else if (prayer.status == 'missed') {
          segmentColor = AppColors.statusMissed;
        } else {
          segmentColor = prayer.inJamaat
              ? AppColors.statusGroup
              : AppColors.statusAlone;
        }
      }

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi,
        false,
        paint,
      );
      return;
    }

    final visualGap = gapAngle;
    final visibleSweep = (2 * pi / totalSegments) - visualGap;

    // The round caps stick out on both sides by strokeWidth / 2 mathematically (along the stroke).
    // The angle they occupy is approximately (strokeWidth / radius) radians total (both caps).
    final capAngle = strokeWidth / radius;
    // We must draw a shorter mathematical arc so visual length (sweep + caps) == visibleSweep
    final sweepAngle = max(0.0, visibleSweep - capAngle);

    double startAngle = -pi / 2; // Start from top

    for (int i = 0; i < totalSegments; i++) {
      final prayer = prayers[i];
      Color segmentColor = AppColors.statusNotLogged;

      if (prayer.isCompleted) {
        if (prayer.status == 'late') {
          segmentColor = AppColors.statusLate;
        } else if (prayer.status == 'missed') {
          segmentColor = AppColors.statusMissed;
        } else {
          segmentColor = prayer.inJamaat
              ? AppColors.statusGroup
              : AppColors.statusAlone;
        }
      }

      final paint = Paint()
        ..color = segmentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Shift the actual drawn arc start point forward by capAngle / 2 so the visible round
      // cap begins exactly at 'startAngle' instead of sticking backwards into the gap space.
      final drawStart = startAngle + capAngle / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        drawStart,
        sweepAngle,
        false,
        paint,
      );

      startAngle += visibleSweep + visualGap;
    }
  }

  @override
  bool shouldRepaint(covariant _StreakRingPainter oldDelegate) => true;
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
                final pct = percentages.length > index
                    ? percentages[index]
                    : 0.0;
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

class _MonthlyCalendar extends StatelessWidget {
  final Map<String, List<Prayer>> historicalLog;
  final int year;
  final int month;
  final PrayerBloc bloc;

  const _MonthlyCalendar({
    required this.historicalLog,
    required this.year,
    required this.month,
    required this.bloc,
  });

  void _goToPreviousMonth() {
    int newMonth = month - 1;
    int newYear = year;
    if (newMonth < 1) {
      newMonth = 12;
      newYear -= 1;
    }
    bloc.add(LoadMonthHistory(year: newYear, month: newMonth));
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    int newMonth = month + 1;
    int newYear = year;
    if (newMonth > 12) {
      newMonth = 1;
      newYear += 1;
    }
    // Don't allow navigating past the current month
    if (newYear > now.year || (newYear == now.year && newMonth > now.month)) {
      return;
    }
    bloc.add(LoadMonthHistory(year: newYear, month: newMonth));
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final startWeekday = firstDayOfMonth.weekday; // 1=Monday, 7=Sunday
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;
    final isFutureBlocked = isCurrentMonth; // Can't go forward past current month

    // Calculate total grid items (padding before 1st day + days in month)
    final totalGridItems = (startWeekday - 1) + daysInMonth;

    return NeoCard(
      color: AppColors.primary,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(month)} $year',
                style: AppTextStyles.headlineMedium,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _goToPreviousMonth,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentFocus.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isFutureBlocked ? null : _goToNextMonth,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentFocus.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isFutureBlocked
                            ? AppColors.textDark.withValues(alpha: 0.3)
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Days of the week header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentFocus,
              border: Border.all(color: AppColors.textDark, width: 2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .map(
                    (day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Tabular Date Grid
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: const Border(
                left: BorderSide(color: AppColors.textDark, width: 2),
                right: BorderSide(color: AppColors.textDark, width: 2),
                bottom: BorderSide(color: AppColors.textDark, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: const [
                BoxShadow(color: AppColors.textDark, offset: Offset(4, 4)),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 1,
              ),
              // We pad the total grid items to always complete the last row
              itemCount: totalGridItems + (7 - (totalGridItems % 7)) % 7,
              itemBuilder: (context, index) {
                // Empty padding cell (before month start or after month end)
                if (index < startWeekday - 1 || index >= totalGridItems) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      border: Border.all(color: AppColors.textDark, width: 0.5),
                    ),
                  );
                }

                final dayIndex = index - (startWeekday - 1) + 1;
                final date = DateTime(year, month, dayIndex);
                final m = date.month.toString().padLeft(2, '0');
                final d = date.day.toString().padLeft(2, '0');
                final dateString = '${date.year}-$m-$d';
                final prayers = historicalLog[dateString] ?? [];

                return Container(
                  decoration: BoxDecoration(
                    color: prayers.isNotEmpty
                        ? AppColors.surface
                        : AppColors.backgroundLight,
                    border: Border.all(color: AppColors.textDark, width: 0.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (prayers.isNotEmpty)
                        CustomPaint(
                          size: const Size.square(42),
                          painter: _StreakRingPainter(
                            prayers: prayers,
                            strokeWidth: 3.0,
                            gapAngle: 0.1,
                          ),
                        ),
                      Text(
                        '$dayIndex',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: prayers.isNotEmpty
                              ? AppColors.textDark
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }
}

class _TopReasons extends StatelessWidget {
  final Map<String, int> reasonCounts;

  const _TopReasons({required this.reasonCounts});

  @override
  Widget build(BuildContext context) {
    final sortedReasons = reasonCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topReasonsList = sortedReasons.take(3).toList();

    return NeoCard(
      color: AppColors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Reasons', style: AppTextStyles.headlineMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentFocus.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Missed/Late',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topReasonsList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No missed or late prayers logged yet. Great job!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
            )
          else
            ...topReasonsList.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.statusMissed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
