import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:namaz_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:namaz_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:namaz_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/prayer_time_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_text_field.dart';
import '../../../../core/widgets/neo_toggle.dart';
import '../../../../core/widgets/neo_settings_tile.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';
import 'settings/notifications_settings_page.dart';
import 'settings/calculation_settings_page.dart';
import 'settings/reasons_settings_page.dart';

/// Profile Page — matches profile.html Stitch mockup.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Human-readable labels for calculation methods.
  static const Map<String, String> _methodLabels = {
    'ISNA': 'ISNA (Islamic Society of NA)',
    'MWL': 'MWL (Muslim World League)',
    'Egyptian': 'Egyptian General Authority',
    'Umm Al-Qura': 'Umm Al-Qura (Makkah)',
    'Karachi': 'University of Islamic Sciences, Karachi',
    'Dubai': 'Dubai',
    'Kuwait': 'Kuwait',
    'Qatar': 'Qatar',
    'Singapore': 'Singapore',
    'Tehran': 'Tehran',
    'Turkey': 'Diyanet İşleri Başkanlığı (Turkey)',
  };

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

  // ─── Edit Profile Bottom Sheet ───
  void _showEditProfileSheet(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    final firstNameController = TextEditingController(text: user?.firstName ?? '');
    final lastNameController = TextEditingController(text: user?.lastName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border, width: 2),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag indicator
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
              Text('Edit Profile', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 24),
              NeoTextField(
                label: 'First Name',
                hint: 'Enter your first name',
                controller: firstNameController,
              ),
              const SizedBox(height: 16),
              NeoTextField(
                label: 'Last Name',
                hint: 'Enter your last name',
                controller: lastNameController,
              ),
              const SizedBox(height: 24),
              NeoButton(
                text: 'Save Changes',
                color: AppColors.primary,
                onPressed: () {
                  final firstName = firstNameController.text.trim();
                  final lastName = lastNameController.text.trim();
                  if (firstName.isNotEmpty) {
                    context.read<AuthBloc>().add(
                      UpdateProfileRequested(
                        firstName: firstName,
                        lastName: lastName,
                      ),
                    );
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: AppColors.streak,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              NeoButton(
                text: 'Cancel',
                color: AppColors.surface,
                textColor: AppColors.textDark,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Logout Confirmation ───
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 2),
        ),
        title: Text('Log Out', style: AppTextStyles.headlineMedium),
        content: Text(
          'Are you sure you want to log out? Your locally-saved data will be preserved.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
            ),
          ),
          NeoButton(
            text: 'Log Out',
            color: AppColors.primary,
            isFullWidth: false,
            height: 44,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  // ─── Delete Account Confirmation ───
  void _showDeleteAccountDialog(BuildContext context) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.redAccent, size: 28),
              const SizedBox(width: 8),
              Text('Delete Account',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: Colors.redAccent)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will log you out locally. Your account and prayer data will remain on our server until server-side deletion is available. To fully delete your data, please contact support.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Type DELETE to confirm:',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                onChanged: (_) => setDialogState(() {}),
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Colors.redAccent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
              ),
            ),
            NeoButton(
              text: 'Delete',
              color: confirmController.text == 'DELETE'
                  ? Colors.redAccent
                  : AppColors.muted,
              isFullWidth: false,
              height: 44,
              onPressed: confirmController.text == 'DELETE'
                  ? () {
                      Navigator.of(dialogContext).pop();
                      // Server-side deletion API not yet available — local logout only
                      context.read<AuthBloc>().add(LogoutRequested());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'You have been logged out. To fully delete your account data, please contact support.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
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
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final user = authState.user;
                      final name = (user?.firstName != null &&
                              user!.firstName.isNotEmpty)
                          ? '${user.firstName} ${user.lastName}'
                          : (user?.username ?? 'User');
                      final email = user?.email ?? 'No email';
                      final initials = (user?.firstName != null &&
                              user!.firstName.isNotEmpty)
                          ? '${user.firstName[0]}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'
                          : (user?.username.isNotEmpty == true
                              ? user!.username[0].toUpperCase()
                              : 'U');

                      return NeoCard(
                        color: AppColors.streak,
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.border, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style:
                                          AppTextStyles.headlineMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: AppTextStyles.headlineMedium),
                                      Text(
                                        email,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textDark
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Streak badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(9999),
                                          border: Border.all(
                                              color: AppColors.border, width: 2),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: AppColors.border,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.local_fire_department,
                                                color: AppColors.primary,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                                '${state.streak.currentStreak} Day Streak!',
                                                style: AppTextStyles.badge),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Edit Icon Button
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () => _showEditProfileSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.border, width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.border,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.edit,
                                      size: 18, color: AppColors.textDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ── Settings List ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      NeoSettingsTile(
                        title: 'Notifications',
                        subtitle: 'Manage prayer alerts & reminders',
                        icon: Icons.notifications,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryLight,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsSettingsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      NeoSettingsTile(
                        title: 'Theme',
                        subtitle: 'Change app appearance',
                        icon: Icons.color_lens,
                        iconColor: AppColors.jamaat,
                        iconBg: AppColors.jamaatLight,
                        onTap: () => _showPlaceholderSheet(context, 'Theme'),
                      ),
                      const SizedBox(height: 16),
                      NeoSettingsTile(
                        title: 'Salah Times Settings',
                        subtitle: 'Manage calculation methods and offsets',
                        icon: Icons.access_time,
                        iconColor: AppColors.streak,
                        iconBg: AppColors.streakLight,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CalculationSettingsPage(),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReasonsSettingsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      NeoSettingsTile(
                        title: 'Change Start Date',
                        subtitle: 'Adjust the date your tracking began',
                        icon: Icons.date_range,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryLight,
                        onTap: () => _showPlaceholderSheet(context, 'Change Start Date'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Data Management ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        onTap: () => _showPlaceholderSheet(context, 'Import Data'),
                      ),
                      const SizedBox(height: 16),
                      NeoSettingsTile(
                        title: 'Export Data',
                        icon: Icons.file_upload,
                        iconColor: AppColors.textDark,
                        iconBg: AppColors.backgroundLight,
                        onTap: () => _showPlaceholderSheet(context, 'Export Data'),
                      ),
                      const SizedBox(height: 16),
                      NeoSettingsTile(
                        title: 'Leave a Review',
                        icon: Icons.star_rate,
                        iconColor: Colors.amber,
                        iconBg: Colors.amber.withValues(alpha: 0.2),
                        onTap: () => _showPlaceholderSheet(context, 'Review'),
                      ),
                      const SizedBox(height: 16),
                      NeoSettingsTile(
                        title: 'Share the App',
                        icon: Icons.share,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryLight,
                        onTap: () => _showPlaceholderSheet(context, 'Share'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Account Actions ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      NeoButton(
                        text: 'Log Out',
                        icon: Icons.logout,
                        onPressed: () => _showLogoutDialog(context),
                      ),
                      const SizedBox(height: 16),
                      // Delete account button
                      GestureDetector(
                        onTap: () => _showDeleteAccountDialog(context),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.muted,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Delete Account',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
