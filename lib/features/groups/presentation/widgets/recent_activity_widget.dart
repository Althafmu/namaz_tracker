import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../data/models/group_dashboard_model.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivityWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final displayActivities = activities.take(20).toList();

    return NeoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: AppTextStyles.sectionHeader.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 12),
            if (displayActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'No activity yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invite members to start building streaks together',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
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
    final c = AppColors.of(context);

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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: c.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.message ?? activity.type,
                  style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
                ),
                if (activity.username != null)
                  Text(
                    activity.username!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: c.textSecondary,
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