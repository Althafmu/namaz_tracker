import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_button.dart';
import '../../../../../core/widgets/neo_settings_tile.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';
import '../profile/widgets/theme_selection_sheet.dart';

/// Full-screen settings hub — accessed via gear icon on the Profile page.
class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  void _showPlaceholderSheet(
    BuildContext context,
    String title,
    String description,
  ) {
    final c = AppColors.of(context);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: c.border, width: 2),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                'Planned for an upcoming release.',
                style: AppTextStyles.bodySmall.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: 24),
              NeoButton(
                text: 'Got it',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.headlineMedium.copyWith(color: c.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsBloc, SettingsState>(
          buildWhen: (prev, curr) =>
              prev.themeMode != curr.themeMode ||
              prev.notificationsPausedToday != curr.notificationsPausedToday ||
              prev.pauseActionStatus != curr.pauseActionStatus ||
              prev.intentLevel != curr.intentLevel ||
              prev.sunnahEnabled != curr.sunnahEnabled ||
              prev.qadaTrackingEnabled != curr.qadaTrackingEnabled,
          builder: (context, settingsState) {
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Prayer Settings ──
                  NeoSettingsTile(
                    title: 'Notifications',
                    subtitle: 'Manage prayer alerts & reminders',
                    icon: Icons.notifications,
                    iconColor: c.primary,
                    iconBg: c.primaryLight,
                    onTap: () => context.push('/settings/notifications'),
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
                        settingsState.pauseActionStatus ==
                            PauseActionStatus.loading
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
                    onTap: () => showThemeSelectionSheet(context),
                  ),
                  const SizedBox(height: 16),
                  NeoSettingsTile(
                    title: 'Salah Times Settings',
                    subtitle: 'Manage calculation methods and offsets',
                    icon: Icons.access_time,
                    iconColor: c.streak,
                    iconBg: c.streakLight,
                    onTap: () => context.push('/settings/calculation'),
                  ),
                  const SizedBox(height: 16),
                  if (settingsState.intentLevel == IntentLevel.growth) ...[
                    NeoSettingsTile(
                      title: 'Sunna Tracker',
                      subtitle: settingsState.sunnahEnabled
                          ? 'Enabled for your Growth plan and shown on Home.'
                          : 'Enable optional Sunna tracking for your Growth plan.',
                      icon: Icons.auto_awesome,
                      iconColor: c.jamaat,
                      iconBg: c.jamaatLight,
                      isToggle: true,
                      toggleValue: settingsState.sunnahEnabled,
                      onToggleChanged: (val) {
                        context.read<SettingsBloc>().add(
                          UpdateSunnahEnabled(val),
                        );
                      },
                    ),
                  ] else ...[
                    NeoSettingsTile(
                      title: 'Sunna Tracker',
                      subtitle:
                          'Visible in Growth mode. Tap to switch your path and unlock it.',
                      icon: Icons.auto_awesome,
                      iconColor: c.jamaat,
                      iconBg: c.jamaatLight,
                      onTap: () => context.go('/intent-setup'),
                    ),
                  ],
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
                    onTap: () => context.push('/settings/reasons'),
                  ),
                  const SizedBox(height: 16),
                  NeoSettingsTile(
                    title: 'Change Start Date',
                    subtitle:
                        'Coming soon: adjust the date your tracking began',
                    icon: Icons.date_range,
                    iconColor: c.primary,
                    iconBg: c.primaryLight,
                    onTap: () => _showPlaceholderSheet(
                      context,
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
                    onTap: () => _showPlaceholderSheet(
                      context,
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
                    onTap: () => _showPlaceholderSheet(
                      context,
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
                    onTap: () => _showPlaceholderSheet(
                      context,
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
                    onTap: () => _showPlaceholderSheet(
                      context,
                      'Share the App',
                      'Send an install link to people in your circle directly from the app.',
                    ),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'Falah v0.1.0',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
