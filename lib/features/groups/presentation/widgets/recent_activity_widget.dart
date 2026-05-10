import 'package:flutter/material.dart';
import '../../data/models/group_dashboard_model.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final displayActivities = activities.take(20).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (displayActivities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'No activity yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invite members to start building streaks together',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...displayActivities.map((activity) => _ActivityRow(
                    activity: activity,
                  )),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (activity.type) {
      case 'streak_milestone':
        icon = Icons.local_fire_department;
        break;
      case 'join':
        icon = Icons.person_add;
        break;
      case 'completion':
        icon = Icons.check_circle;
        break;
      default:
        icon = Icons.notifications;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.message ?? activity.type,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (activity.username != null)
                  Text(
                    activity.username!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}