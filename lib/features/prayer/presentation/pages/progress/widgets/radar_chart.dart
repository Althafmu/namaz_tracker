import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/services/time_service.dart';
import '../../../../../prayer/domain/entities/prayer.dart';

/// Radar chart showing prayer completion distribution over the last 7 days.
/// Each axis represents a prayer type; radius shows how many days that prayer was completed.
class PrayerRadarChart extends StatelessWidget {
  final Map<String, List<Prayer>> historicalLog;
  final AppColorPalette colors;

  const PrayerRadarChart({
    super.key,
    required this.historicalLog,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final counts = _computeCounts();

    return SizedBox(
      height: 220,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 3,
          ticksTextStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: 10,
          ),
          tickBorderData: BorderSide(
            color: colors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          gridBorderData: BorderSide(
            color: colors.border.withValues(alpha: 0.2),
            width: 1,
          ),
          radarBorderData: BorderSide(
            color: colors.border,
            width: 2,
          ),
          titleTextStyle: TextStyle(
            color: colors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          getTitle: (index, angle) {
            const labels = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
            return RadarChartTitle(text: labels[index]);
          },
          titlePositionPercentageOffset: 0.15,
          dataSets: [
            RadarDataSet(
              fillColor: colors.primary.withValues(alpha: 0.25),
              borderColor: colors.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: counts['fajr']!.toDouble()),
                RadarEntry(value: counts['dhuhr']!.toDouble()),
                RadarEntry(value: counts['asr']!.toDouble()),
                RadarEntry(value: counts['maghrib']!.toDouble()),
                RadarEntry(value: counts['isha']!.toDouble()),
              ],
            ),
          ],
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Map<String, int> _computeCounts() {
    final effectiveNow = TimeService.effectiveNow();
    final counts = {'fajr': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0};

    for (int i = 0; i < 7; i++) {
      final date = effectiveNow.subtract(Duration(days: i));
      final key = _formatDate(date);
      final prayers = historicalLog[key] ?? [];

      for (final prayer in prayers) {
        if (prayer.isCompleted && !prayer.isExcused) {
          final key = prayer.name.toLowerCase();
          if (counts.containsKey(key)) {
            counts[key] = counts[key]! + 1;
          }
        }
      }
    }

    return counts;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}