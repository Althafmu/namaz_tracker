import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_settings_tile.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/settings/settings_state.dart';
import 'theme_selection_sheet.dart';

/// Main settings tiles list and data & community section.
class SettingsList extends StatelessWidget {
  final void Function(String title) onPlaceholderTap;

  const SettingsList({super.key, required this.onPlaceholderTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
      builder: (context, settingsState) {
        
        // Determine Theme Title/Subtitle/Icon based on themeMode
        String themeSubtitle;
        IconData themeIcon;
        if (settingsState.themeMode == 'dark') {
          themeSubtitle = 'Dark Mode';
          themeIcon = Icons.dark_mode;
        } else if (settingsState.themeMode == 'light') {
          themeSubtitle = 'Light Mode';
          themeIcon = Icons.light_mode;
        } else {
          themeSubtitle = 'System Default';
          themeIcon = Icons.brightness_auto;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Settings ──
            NeoSettingsTile(
              title: 'Notifications',
              subtitle: 'Manage prayer alerts & reminders',
              icon: Icons.notifications,
              iconColor: c.primary,
              iconBg: c.primaryLight,
              onTap: () {
                context.go('/settings/notifications');
              },
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'App Theme',
              subtitle: themeSubtitle,
              icon: themeIcon,
              iconColor: c.jamaat,
              iconBg: c.jamaatLight,
              onTap: () {
                showThemeSelectionSheet(context);
              },
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Salah Times Settings',
              subtitle: 'Manage calculation methods and offsets',
              icon: Icons.access_time,
              iconColor: c.streak,
              iconBg: c.streakLight,
              onTap: () {
                context.go('/settings/calculation');
              },
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Missed Salah Counter',
              subtitle: 'Include tracker for Qaza prayers',
              icon: Icons.assignment_late,
              iconColor: c.error,
              iconBg: c.error.withValues(alpha: 0.2),
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
              iconColor: c.textPrimary,
              iconBg: c.background,
              onTap: () {
                context.go('/settings/reasons');
              },
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Change Start Date',
              subtitle: 'Adjust the date your tracking began',
              icon: Icons.date_range,
              iconColor: c.primary,
              iconBg: c.primaryLight,
              onTap: () => onPlaceholderTap('Change Start Date'),
            ),

            const SizedBox(height: 32),

            // ── Data & Community ──
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text('DATA & COMMUNITY', style: AppTextStyles.sectionHeader.copyWith(
                color: c.textSecondary,
              )),
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Import Data',
              icon: Icons.file_download,
              iconColor: c.textPrimary,
              iconBg: c.background,
              onTap: () => onPlaceholderTap('Import Data'),
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Export Data',
              icon: Icons.file_upload,
              iconColor: c.textPrimary,
              iconBg: c.background,
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
              iconColor: c.primary,
              iconBg: c.primaryLight,
              onTap: () => onPlaceholderTap('Share'),
            ),
          ],
        );
      },
    );
  }
}
