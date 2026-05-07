import 'package:flutter/material.dart';
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
    final prayers = [
      ('Fajr', Icons.wb_sunny_outlined, stats.fajr),
      ('Dhuhr', Icons.wb_sunny_outlined, stats.dhuhr),
      ('Asr', Icons.wb_sunny_outlined, stats.asr),
      ('Maghrib', Icons.wb_twilight, stats.maghrib),
      ('Isha', Icons.nightlight_outlined, stats.isha),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Completion",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(name)),
              Text(
                '$completed/$total',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}