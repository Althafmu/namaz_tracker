import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../data/models/group_dashboard_model.dart';

class TodayCompletionWidget extends StatelessWidget {
  final TodayCompletionStats stats;
  final int memberCount;

  const TodayCompletionWidget({
    super.key,
    required this.stats,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final prayers = [
      ('Fajr', Icons.wb_sunny_outlined, stats.fajr),
      ('Dhuhr', Icons.wb_sunny_outlined, stats.dhuhr),
      ('Asr', Icons.wb_sunny_outlined, stats.asr),
      ('Maghrib', Icons.wb_twilight, stats.maghrib),
      ('Isha', Icons.nightlight_outlined, stats.isha),
    ];

    return NeoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "TODAY'S COMPLETION",
              style: AppTextStyles.sectionHeader.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 16),
            ...prayers.map((prayer) => _PrayerProgressRow(
                  name: prayer.$1,
                  icon: prayer.$2,
                  completed: prayer.$3,
                  total: memberCount,
                )),
          ],
        ),
      ),
    );
  }
}

class _PrayerProgressRow extends StatelessWidget {
  final String name;
  final IconData icon;
  final int completed;
  final int total;

  const _PrayerProgressRow({
    required this.name,
    required this.icon,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: c.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
                ),
              ),
              Text(
                '$completed/$total',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: c.border, width: 1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}