import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/services/time_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_settings_tile.dart';
import '../../bloc/streak/streak_bloc.dart';
import '../../bloc/streak/streak_state.dart';
import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_event.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';
import 'widgets/user_info_card.dart';
import 'widgets/account_actions.dart';
import '../home/widgets/excused_day_dialog.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/delete_account_dialog.dart';

/// Profile Page — clean view with user info, excused mode, and account actions.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showExcusedModeDialog(BuildContext context) {
    final today = TimeService.effectiveNow();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    showDialog<bool>(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<StreakBloc>()),
          BlocProvider.value(value: context.read<PrayerBloc>()),
        ],
        child: ExcusedDayDialog(date: dateKey),
      ),
    ).then((didChange) {
      if (didChange == true && context.mounted) {
        context.read<PrayerBloc>().add(const LoadDailyStatus());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, streakState) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header with gear icon ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Profile',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Settings',
                        child: GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: c.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.border, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: c.border,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.settings,
                              size: 20,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── User Info Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: UserInfoCard(
                    displayStreak: streakState.streak.displayStreak,
                    onEditTap: () => showEditProfileSheet(context),
                    onStreakTap: () => context.go('/progress'),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Excused Mode ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (prev, curr) =>
                        prev.excusedDays != curr.excusedDays,
                    builder: (context, settingsState) {
                      return NeoSettingsTile(
                        title: settingsState.isExcused
                            ? 'Excused Mode Active'
                            : 'Excused Mode',
                        subtitle: settingsState.isExcused
                            ? 'Today is marked excused. Open it to resume normal logging if needed.'
                            : 'Mark today for travel, sickness, or period.',
                        icon: Icons.event_busy,
                        iconColor: c.statusExcused,
                        iconBg: c.statusExcused.withValues(alpha: 0.15),
                        onTap: () => _showExcusedModeDialog(context),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Quick Settings ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (prev, curr) =>
                        prev.notificationsPausedToday !=
                            curr.notificationsPausedToday ||
                        prev.pauseActionStatus != curr.pauseActionStatus,
                    builder: (context, settingsState) {
                      return Column(
                        children: [
                          NeoSettingsTile(
                            title: 'Notifications',
                            subtitle: 'Manage prayer alerts',
                            icon: Icons.notifications,
                            iconColor: c.primary,
                            iconBg: c.primaryLight,
                            onTap: () =>
                                context.push('/settings/notifications'),
                          ),
                          const SizedBox(height: 12),
                          NeoSettingsTile(
                            title: 'Salah Times',
                            subtitle: 'Calculation methods & offsets',
                            icon: Icons.access_time,
                            iconColor: c.streak,
                            iconBg: c.streakLight,
                            onTap: () => context.push('/settings/calculation'),
                          ),
                          const SizedBox(height: 12),
                          NeoSettingsTile(
                            title: 'Pause Notifications',
                            subtitle: settingsState.notificationsPausedToday
                                ? 'Paused for today'
                                : 'Pause all alerts for today',
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
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ── Account Actions ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AccountActions(
                    onLogout: () => showLogoutDialog(context),
                    onDeleteAccount: () => showDeleteAccountDialog(context),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
