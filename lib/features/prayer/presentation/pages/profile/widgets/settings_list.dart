import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_settings_tile.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/settings/settings_event.dart';
import '../../../bloc/settings/settings_state.dart';
import 'theme_selection_sheet.dart';

/// Main settings tiles list and data & community section.
class SettingsList extends StatelessWidget {
  final void Function(String title, String description) onPlaceholderTap;
  final VoidCallback onExcusedModeTap;

  const SettingsList({
    super.key,
    required this.onPlaceholderTap,
    required this.onExcusedModeTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.themeMode != curr.themeMode ||
          prev.notificationsPausedToday != curr.notificationsPausedToday ||
          prev.pauseActionStatus != curr.pauseActionStatus ||
          prev.intentLevel != curr.intentLevel ||
          prev.sunnahEnabled != curr.sunnahEnabled ||
          prev.qadaTrackingEnabled != curr.qadaTrackingEnabled ||
          prev.excusedDays != curr.excusedDays,
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
              title: 'Pause Notifications Today',
              subtitle: settingsState.notificationsPausedToday
                  ? 'Paused for today'
                  : 'Pause all alerts for the rest of today',
              icon: settingsState.notificationsPausedToday
                  ? Icons.notifications_paused
                  : Icons.notifications_off_outlined,
              iconColor: settingsState.notificationsPausedToday
                  ? c.textSecondary
                  : c.primary,
              iconBg: settingsState.notificationsPausedToday
                  ? c.border
                  : c.primaryLight,
              isToggle: true,
              toggleValue: settingsState.notificationsPausedToday,
              onToggleChanged:
                  settingsState.pauseActionStatus == PauseActionStatus.loading
                  ? null
                  : (val) {
                      if (val) {
                        context.read<SettingsBloc>().add(
                          const PauseNotificationsForToday(),
                        );
                      }
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
            if (settingsState.intentLevel == IntentLevel.growth) ...[
              NeoSettingsTile(
                title: 'Sunna Tracker',
                subtitle: settingsState.sunnahEnabled
                    ? 'Enabled for your Growth plan. Dedicated tracking UI comes next.'
                    : 'Enable optional Sunna tracking for your Growth plan.',
                icon: Icons.auto_awesome,
                iconColor: c.jamaat,
                iconBg: c.jamaatLight,
                isToggle: true,
                toggleValue: settingsState.sunnahEnabled,
                onToggleChanged: (val) {
                  context.read<SettingsBloc>().add(UpdateSunnahEnabled(val));
                },
              ),
            ] else ...[
              NeoSettingsTile(
                title: 'Sunna Tracker',
                subtitle: 'Visible in Growth mode. Tap to switch your path and unlock it.',
                icon: Icons.auto_awesome,
                iconColor: c.jamaat,
                iconBg: c.jamaatLight,
                onTap: () => context.go('/intent-setup'),
              ),
            ],
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: settingsState.isExcused
                  ? 'Excused Mode Active'
                  : 'Excused Mode',
              subtitle: settingsState.isExcused
                  ? 'Today is marked excused for travel, sickness, or period.'
                  : 'Mark today for travel, sickness, or period.',
              icon: Icons.event_busy,
              iconColor: c.statusExcused,
              iconBg: c.statusExcused.withValues(alpha: 0.15),
              onTap: onExcusedModeTap,
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Qada Tracking',
              subtitle: settingsState.qadaTrackingEnabled
                  ? 'Active. Qada recovery analytics are visible in Progress.'
                  : 'Turn on Qada recovery analytics in Progress.',
              icon: Icons.assignment_late,
              iconColor: c.statusQada,
              iconBg: c.statusQada.withValues(alpha: 0.15),
              isToggle: true,
              toggleValue: settingsState.qadaTrackingEnabled,
              onToggleChanged: (val) {
                context.read<SettingsBloc>().add(
                  UpdateQadaTrackingEnabled(val),
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
              subtitle: 'Coming soon: adjust the date your tracking began',
              icon: Icons.date_range,
              iconColor: c.primary,
              iconBg: c.primaryLight,
              onTap: () => onPlaceholderTap(
                'Change Start Date',
                'Backdate your initial tracking day without losing streak history integrity.',
              ),
            ),

            const SizedBox(height: 32),

            // ── Data & Community ──
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'DATA & COMMUNITY',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Import Data',
              subtitle: 'Coming soon: restore a previous backup',
              icon: Icons.file_download,
              iconColor: c.textPrimary,
              iconBg: c.background,
              onTap: () => onPlaceholderTap(
                'Import Data',
                'Restore your prayer logs from an exported backup file.',
              ),
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Export Data',
              subtitle: 'Coming soon: download your prayer history',
              icon: Icons.file_upload,
              iconColor: c.textPrimary,
              iconBg: c.background,
              onTap: () => onPlaceholderTap(
                'Export Data',
                'Download your prayer and streak history for backup or transfer.',
              ),
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Leave a Review',
              subtitle: 'Coming soon: rate the app in your store',
              icon: Icons.star_rate,
              iconColor: Colors.amber,
              iconBg: Colors.amber.withValues(alpha: 0.2),
              onTap: () => onPlaceholderTap(
                'Leave a Review',
                'Open your app store listing and share your feedback.',
              ),
            ),
            const SizedBox(height: 16),
            NeoSettingsTile(
              title: 'Share the App',
              subtitle: 'Coming soon: share with friends and family',
              icon: Icons.share,
              iconColor: c.primary,
              iconBg: c.primaryLight,
              onTap: () => onPlaceholderTap(
                'Share the App',
                'Send an install link to people in your circle directly from the app.',
              ),
            ),
          ],
        );
      },
    );
  }
}
