import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/neo_button.dart';
import '../../bloc/prayer/prayer_bloc.dart';
import '../../bloc/prayer/prayer_state.dart';
import 'widgets/user_info_card.dart';
import 'widgets/settings_list.dart';
import 'widgets/account_actions.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/delete_account_dialog.dart';

/// Settings Page (formerly Profile Page).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // ─── Placeholder Sheet ───
  void _showPlaceholderSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border, width: 2),
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
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),
              Text('This feature is coming soon!', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),
              NeoButton(
                text: 'Got it',
                color: AppColors.primary,
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
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Text('Profile', style: AppTextStyles.headlineLarge),
                ),

                const SizedBox(height: 24),

                // ── User Info Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: UserInfoCard(
                    currentStreak: state.streak.currentStreak,
                    onEditTap: () => showEditProfileSheet(context),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Settings List ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SettingsList(
                    onPlaceholderTap: (title) =>
                        _showPlaceholderSheet(context, title),
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
