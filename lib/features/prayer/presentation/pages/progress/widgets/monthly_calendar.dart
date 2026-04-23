import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../../../core/services/time_service.dart';
import '../../../../domain/entities/prayer.dart';
import '../../../bloc/history/history_bloc.dart';
import '../../../bloc/history/history_event.dart';
import 'streak_ring_painter.dart';

/// Monthly calendar heatmap with prayer status rings per day.
class MonthlyCalendar extends StatelessWidget {
  final Map<String, List<Prayer>> historicalLog;
  final int year;
  final int month;
  final HistoryBloc bloc;

  const MonthlyCalendar({
    super.key,
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
    final now = TimeService.effectiveNow();
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
    final c = AppColors.of(context);
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final startWeekday = firstDayOfMonth.weekday; // 1=Monday, 7=Sunday
    final now = TimeService.effectiveNow();
    final isCurrentMonth = year == now.year && month == now.month;
    final isFutureBlocked =
        isCurrentMonth; // Can't go forward past current month

    // Calculate total grid items (padding before 1st day + days in month)
    final totalGridItems = (startWeekday - 1) + daysInMonth;

    return NeoCard(
      color: c.primary,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(month)} $year',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: c.textPrimary,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _goToPreviousMonth,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.accentFocus.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isFutureBlocked ? null : _goToNextMonth,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.accentFocus.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isFutureBlocked
                            ? c.textPrimary.withValues(alpha: 0.3)
                            : c.textPrimary,
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
              color: c.accentFocus,
              border: Border.all(color: c.borderPrimary, width: 2),
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
              color: c.background,
              border: Border(
                left: BorderSide(color: c.border, width: 2),
                right: BorderSide(color: c.border, width: 2),
                bottom: BorderSide(color: c.border, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(color: c.border, offset: const Offset(4, 4)),
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
                      color: c.background,
                      border: Border.all(
                        color: c.border.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
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
                    color: prayers.isNotEmpty ? c.surface : c.background,
                    border: Border.all(
                      color: c.border.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (prayers.isNotEmpty)
                        CustomPaint(
                          size: const Size.square(42),
                          painter: StreakRingPainter(
                            prayers: prayers,
                            colors: c,
                            strokeWidth: 3.0,
                            gapAngle: 0.1,
                          ),
                        ),
                      Text(
                        '$dayIndex',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: prayers.isNotEmpty
                              ? c.textPrimary
                              : c.textSecondary,
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
