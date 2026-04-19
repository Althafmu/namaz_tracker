import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/services/time_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_button.dart';
import '../../bloc/streak/streak_bloc.dart';
import '../../bloc/streak/streak_state.dart';
import 'widgets/user_info_card.dart';
import 'widgets/settings_list.dart';
import 'widgets/account_actions.dart';
import '../home/widgets/excused_day_dialog.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/delete_account_dialog.dart';

/// Settings Page (formerly Profile Page).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // ─── Placeholder Sheet ───
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

  void _showExcusedModeDialog(BuildContext context) {
    final today = TimeService.effectiveNow();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<StreakBloc>(),
        child: ExcusedDayDialog(date: dateKey),
      ),
    );
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
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Text(
                    'Profile',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: c.textPrimary,
                    ),
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

                const SizedBox(height: 32),

                // ── Settings List ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SettingsList(
                    onPlaceholderTap: (title, description) =>
                        _showPlaceholderSheet(context, title, description),
                    onExcusedModeTap: () => _showExcusedModeDialog(context),
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
