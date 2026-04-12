import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_settings_tile.dart';

/// Main settings tiles list and data & community section.
class SettingsList extends StatelessWidget {
  final void Function(String title) onPlaceholderTap;

  const SettingsList({super.key, required this.onPlaceholderTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Settings ──
        NeoSettingsTile(
          title: 'Notifications',
          subtitle: 'Manage prayer alerts & reminders',
          icon: Icons.notifications,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          onTap: () {
            context.go('/settings/notifications');
          },
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Theme',
          subtitle: 'Change app appearance',
          icon: Icons.color_lens,
          iconColor: AppColors.jamaat,
          iconBg: AppColors.jamaatLight,
          onTap: () => onPlaceholderTap('Theme'),
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Salah Times Settings',
          subtitle: 'Manage calculation methods and offsets',
          icon: Icons.access_time,
          iconColor: AppColors.streak,
          iconBg: AppColors.streakLight,
          onTap: () {
            context.go('/settings/calculation');
          },
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Missed Salah Counter',
          subtitle: 'Include tracker for Qaza prayers',
          icon: Icons.assignment_late,
          iconColor: AppColors.error,
          iconBg: AppColors.error.withValues(alpha: 0.2),
          isToggle: true,
          toggleValue: false, // Placeholder for future state
          onToggleChanged: (val) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Counter toggle coming soon!')),
            );
          },
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Edit Reasons',
          subtitle: 'Manage reasons for missing or being late',
          icon: Icons.edit_note,
          iconColor: AppColors.textDark,
          iconBg: AppColors.backgroundLight,
          onTap: () {
            context.go('/settings/reasons');
          },
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Change Start Date',
          subtitle: 'Adjust the date your tracking began',
          icon: Icons.date_range,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          onTap: () => onPlaceholderTap('Change Start Date'),
        ),

        const SizedBox(height: 32),

        // ── Data & Community ──
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('DATA & COMMUNITY', style: AppTextStyles.sectionHeader),
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Import Data',
          icon: Icons.file_download,
          iconColor: AppColors.textDark,
          iconBg: AppColors.backgroundLight,
          onTap: () => onPlaceholderTap('Import Data'),
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Export Data',
          icon: Icons.file_upload,
          iconColor: AppColors.textDark,
          iconBg: AppColors.backgroundLight,
          onTap: () => onPlaceholderTap('Export Data'),
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Leave a Review',
          icon: Icons.star_rate,
          iconColor: Colors.amber,
          iconBg: Colors.amber.withValues(alpha: 0.2),
          onTap: () => onPlaceholderTap('Review'),
        ),
        const SizedBox(height: 16),
        NeoSettingsTile(
          title: 'Share the App',
          icon: Icons.share,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          onTap: () => onPlaceholderTap('Share'),
        ),
      ],
    );
  }
}
