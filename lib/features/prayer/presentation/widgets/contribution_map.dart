import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/services/time_service.dart';

/// A GitHub-style contribution/streak heatmap showing prayer completion
/// over the past ~3 months (13 weeks). Each cell represents one day;
/// color intensity maps to the number of prayers completed (0-5).
class ContributionMap extends StatelessWidget {
  /// Date-keyed completion map: 'yyyy-MM-dd' -> completed count (0-5).
  final Map<String, int> history;

  const ContributionMap({super.key, required this.history});

  // Number of full weeks to display (13 weeks ≈ 3 months).
  static const int _weeksToShow = 13;

  // Color scale: index = completed prayers (0-5).
  // Semantic colors that work well in both themes.
  static const List<Color> _colorScale = [
    Color(0xFFEBEDF0), // 0 prayers — grey
    Color(0xFFFFE0B2), // 1 prayer  — light amber
    Color(0xFFFFC973), // 2 prayers — amber
    Color(0xFFFF9800), // 3 prayers — orange
    Color(0xFFFF6B6B), // 4 prayers — coral/primary
    Color(0xFF4ECDC4), // 5 prayers — teal/jamaat (perfect)
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final now = TimeService.effectiveNow();
    // We start from the beginning of the week containing (_weeksToShow - 1)
    // weeks ago, so the grid is a neat rectangle.
    // weekday: Mon=1 … Sun=7.
    final todayWeekday = now.weekday; // 1=Mon … 7=Sun
    final startOfThisWeek = now.subtract(Duration(days: todayWeekday - 1));
    final gridStart =
        startOfThisWeek.subtract(Duration(days: (_weeksToShow - 1) * 7));

    // Build a 7-row × _weeksToShow-column grid, but the last column may be
    // partial (only up to today).
    final totalDays = now.difference(gridStart).inDays + 1;

    // Day labels for the left axis (Mon, Wed, Fri).
    const dayLabels = ['M', '', 'W', '', 'F', '', 'S'];

    return NeoCard(
      color: c.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Prayer Heatmap',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w700, color: c.textPrimary)),
              _buildLegend(c),
            ],
          ),
          const SizedBox(height: 12),

          // The heatmap grid
          LayoutBuilder(
            builder: (context, constraints) {
              const labelWidth = 16.0;
              final availableWidth = constraints.maxWidth - labelWidth - 4;
              final cellSize = (availableWidth / _weeksToShow) - 2;
              final clampedCell = cellSize.clamp(8.0, 14.0);
              final cellTotalSize = clampedCell + 2;
              final columnWidth = cellTotalSize;

              final monthLabels = _buildMonthLabels(gridStart, totalDays, columnWidth);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day labels column
                  Container(
                    width: labelWidth,
                    padding: const EdgeInsets.only(top: 18),
                    child: Column(
                      children: dayLabels
                          .map((label) => Container(
                                height: cellTotalSize,
                                alignment: Alignment.center,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: c.textSecondary,
                                    height: 1.0,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Grid
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month labels
                        SizedBox(
                          height: 14,
                          child: Row(
                            children: monthLabels.map((ml) {
                              return SizedBox(
                                width: ml.width,
                                child: Text(
                                  ml.label,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: c.textSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // The actual grid
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(_weeksToShow, (weekIdx) {
                            return Column(
                              children: List.generate(7, (dayIdx) {
                                final dayOffset = weekIdx * 7 + dayIdx;
                                final date = gridStart
                                    .add(Duration(days: dayOffset));

                                // Don't render future dates.
                                if (date.isAfter(now)) {
                                  return SizedBox(
                                    width: cellTotalSize,
                                    height: cellTotalSize,
                                  );
                                }

                                final key =
                                    DateFormat('yyyy-MM-dd').format(date);
                                final count =
                                    (history[key] ?? 0).clamp(0, 5);

                                return Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Tooltip(
                                    message: '$key: $count/5 prayers',
                                    child: Container(
                                      width: clampedCell,
                                      height: clampedCell,
                                      decoration: BoxDecoration(
                                        color: _colorScale[count],
                                        borderRadius:
                                            BorderRadius.circular(2),
                                        border: Border.all(
                                          color: count == 0
                                              ? const Color(0xFFD1D5DB)
                                              : _colorScale[count]
                                                  .withValues(alpha: 0.7),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Summary stats row
          _buildSummaryRow(c),
        ],
      ),
    );
  }

  Widget _buildLegend(AppColorPalette c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Less ',
            style: TextStyle(fontSize: 9, color: c.textSecondary)),
        ...List.generate(6, (i) {
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _colorScale[i],
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        Text(' More',
            style: TextStyle(fontSize: 9, color: c.textSecondary)),
      ],
    );
  }

  Widget _buildSummaryRow(AppColorPalette c) {
    final now = TimeService.effectiveNow();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    int totalPrayers = 0;
    int activeDays = 0;
    int perfectDays = 0;

    for (final entry in history.entries) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(entry.key);
        if (date.isAfter(thirtyDaysAgo) && !date.isAfter(now)) {
          totalPrayers += entry.value;
          if (entry.value > 0) activeDays++;
          if (entry.value >= 5) perfectDays++;
        }
      } catch (_) {}
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatChip(
          label: 'Active Days',
          value: '$activeDays',
          color: c.streak,
          labelColor: c.textSecondary,
        ),
        _StatChip(
          label: 'Perfect Days',
          value: '$perfectDays',
          color: c.jamaat,
          labelColor: c.textSecondary,
        ),
        _StatChip(
          label: 'Total Prayers',
          value: '$totalPrayers',
          color: c.primary,
          labelColor: c.textSecondary,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color labelColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}

/// Helper class for month label positioning.
class _MonthLabel {
  final String label;
  final double width;
  const _MonthLabel(this.label, this.width);
}

List<_MonthLabel> _buildMonthLabels(DateTime gridStart, int totalDays, double columnWidth) {
  final labels = <_MonthLabel>[];
  int? lastMonth;
  int daysInSegment = 0;

  for (int i = 0; i < totalDays; i++) {
    final date = gridStart.add(Duration(days: i));
    final month = date.month;

    if (lastMonth != null && month != lastMonth) {
      // Flush previous segment
      final segmentWeeks = (daysInSegment / 7).ceil();
      labels.add(_MonthLabel('', segmentWeeks.toDouble() * columnWidth));
      daysInSegment = 0;
    }

    if (lastMonth == null || month != lastMonth) {
      lastMonth = month;
    }
    daysInSegment++;
  }

  // Last segment
  if (daysInSegment > 0) {
    final segmentWeeks = (daysInSegment / 7).ceil();
    labels.add(_MonthLabel('', segmentWeeks.toDouble() * columnWidth));
  }

  // Now put month names — we'll label the first visible column of each month.
  final actualLabels = <_MonthLabel>[];
  int? prevMonth;

  for (int w = 0; w < ContributionMap._weeksToShow; w++) {
    final firstDayOfWeek = gridStart.add(Duration(days: w * 7));
    final month = firstDayOfWeek.month;
    if (prevMonth == null || month != prevMonth) {
      // Count how many weeks this month spans
      int weeksInMonth = 1;
      for (int nw = w + 1; nw < ContributionMap._weeksToShow; nw++) {
        final d = gridStart.add(Duration(days: nw * 7));
        if (d.month == month) {
          weeksInMonth++;
        } else {
          break;
        }
      }
      actualLabels.add(_MonthLabel(
        DateFormat('MMM').format(firstDayOfWeek),
        weeksInMonth * columnWidth,
      ));
      prevMonth = month;
    }
  }

  return actualLabels;
}
