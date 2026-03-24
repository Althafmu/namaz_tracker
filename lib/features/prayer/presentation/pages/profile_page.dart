import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:namaz_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:namaz_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:namaz_tracker/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/services/prayer_time_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../../../core/widgets/neo_text_field.dart';
import '../../../../core/widgets/neo_toggle.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';

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

  // ─── Edit Profile Bottom Sheet ───
  void _showEditProfileSheet(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    final firstNameController = TextEditingController(text: user?.firstName ?? '');
    final lastNameController = TextEditingController(text: user?.lastName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                        child: Row(
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
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ── Prayer Settings ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('PRAYER SETTINGS',
                            style: AppTextStyles.sectionHeader),
                      ),
                      const SizedBox(height: 16),

                      // Calculation Method — functional dropdown
                      NeoCard(
                        color: AppColors.surface,
                        padding: const EdgeInsets.all(20),
                        borderRadius: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Calculation Method',
                                style: AppTextStyles.bodyLarge),
                            const SizedBox(height: 4),
                            Text(
                              'Determines prayer times based on region.',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.border, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.border,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: state.calculationMethod,
                                  isExpanded: true,
                                  icon: const Icon(Icons.expand_more,
                                      color: AppColors.textDark),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                  dropdownColor: AppColors.backgroundLight,
                                  items: PrayerTimeService
                                      .calculationMethods.keys
                                      .map((key) => DropdownMenuItem(
                                            value: key,
                                            child: Text(
                                              _methodLabels[key] ?? key,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<PrayerBloc>().add(
                                            UpdateCalculationSettings(
                                                calculationMethod: value),
                                          );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Asr Method — functional toggle
                      NeoCard(
                        color: AppColors.surface,
                        padding: const EdgeInsets.all(20),
                        borderRadius: 24,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Asr Calculation',
                                      style: AppTextStyles.bodyLarge),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.useHanafi
                                        ? 'Hanafi (Later Asr time)'
                                        : 'Standard (Shafi, Maliki, Hanbali)',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            NeoButton(
                              text: state.useHanafi ? 'Hanafi' : 'Standard',
                              isFullWidth: false,
                              height: 40,
                              color: state.useHanafi
                                  ? AppColors.jamaat
                                  : AppColors.primary,
                              onPressed: () {
                                context.read<PrayerBloc>().add(
                                      UpdateCalculationSettings(
                                          useHanafi: !state.useHanafi),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Notifications ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('NOTIFICATIONS',
                            style: AppTextStyles.sectionHeader),
                      ),
                      const SizedBox(height: 16),
                      NeoCard(
                        color: AppColors.surface,
                        borderRadius: 24,
                        child: Column(
                          children: [
                            // ── Adhan Alerts ──
                            _NotificationRow(
                              icon: Icons.notifications_active,
                              iconColor: AppColors.primary,
                              iconBg: AppColors.primaryLight,
                              title: 'Adhan Alerts',
                              subtitle: state.adhanAlerts
                                  ? 'Active — notification at each prayer time'
                                  : 'Push notifications at prayer time',
                              value: state.adhanAlerts,
                              onChanged: (v) {
                                context.read<PrayerBloc>().add(
                                      UpdateNotificationSettings(
                                          adhanAlerts: v),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(v
                                        ? '✅ Adhan alerts enabled for all 5 prayers'
                                        : '🔕 Adhan alerts turned off'),
                                    backgroundColor:
                                        v ? AppColors.success : AppColors.muted,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              showBorder: true,
                            ),

                            // ── Prayer Reminder ──
                            _NotificationRow(
                              icon: Icons.timer,
                              iconColor: AppColors.jamaat,
                              iconBg: AppColors.jamaatLight,
                              title: 'Prayer Reminder',
                              subtitle: state.reminderAlerts
                                  ? '${state.reminderMinutes} mins ${state.reminderIsBefore ? "before" : "after"} each prayer'
                                  : 'Customizable alert for each prayer',
                              value: state.reminderAlerts,
                              onChanged: (v) {
                                context.read<PrayerBloc>().add(
                                      UpdateNotificationSettings(
                                          reminderAlerts: v),
                                    );
                                if (!v) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('🔕 Prayer reminders turned off'),
                                      backgroundColor: AppColors.muted,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              showBorder: state.reminderAlerts,
                            ),

                            // ── Reminder Settings Card (expanded) ──
                            if (state.reminderAlerts)
                              _ReminderSettingsCard(state: state),

                            // ── Streak Protection ──
                            _NotificationRow(
                              icon: Icons.shield,
                              iconColor: AppColors.streak,
                              iconBg: AppColors.streakLight,
                              title: 'Streak Protection',
                              subtitle: 'Alert if missing last prayer',
                              value: state.streakProtection,
                              onChanged: (v) {
                                context.read<PrayerBloc>().add(
                                      UpdateNotificationSettings(
                                          streakProtection: v),
                                    );
                              },
                              showBorder: false,
                            ),
                          ],
                        ),
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
                        text: 'Edit Profile Details',
                        color: AppColors.surface,
                        textColor: AppColors.textDark,
                        icon: Icons.person,
                        onPressed: () => _showEditProfileSheet(context),
                      ),
                      const SizedBox(height: 16),
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

/// Expanded reminder settings with local editing + Save button.
class _ReminderSettingsCard extends StatefulWidget {
  final PrayerState state;
  const _ReminderSettingsCard({required this.state});

  @override
  State<_ReminderSettingsCard> createState() => _ReminderSettingsCardState();
}

class _ReminderSettingsCardState extends State<_ReminderSettingsCard> {
  late int _minutes;
  late bool _isBefore;

  @override
  void initState() {
    super.initState();
    _minutes = widget.state.reminderMinutes;
    _isBefore = widget.state.reminderIsBefore;
  }

  @override
  void didUpdateWidget(_ReminderSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.reminderMinutes != widget.state.reminderMinutes) {
      _minutes = widget.state.reminderMinutes;
    }
    if (oldWidget.state.reminderIsBefore != widget.state.reminderIsBefore) {
      _isBefore = widget.state.reminderIsBefore;
    }
  }

  bool get _hasChanges =>
      _minutes != widget.state.reminderMinutes ||
      _isBefore != widget.state.reminderIsBefore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Time stepper
          Row(
            children: [
              // Decrease
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.textDark),
                onPressed: () {
                  if (_minutes > 1) setState(() => _minutes--);
                },
              ),
              // Minutes display
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  '$_minutes mins',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              // Increase
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.textDark),
                onPressed: () {
                  if (_minutes < 120) setState(() => _minutes++);
                },
              ),
              const Spacer(),
              // Before/After toggle
              NeoButton(
                text: _isBefore ? 'Before' : 'After',
                isFullWidth: false,
                height: 40,
                color: _isBefore ? AppColors.jamaat : AppColors.primary,
                onPressed: () => setState(() => _isBefore = !_isBefore),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Save button
          NeoButton(
            text: _hasChanges
                ? 'Save Reminder Settings'
                : '✓ Settings Saved',
            color: _hasChanges ? AppColors.primary : AppColors.success,
            icon: _hasChanges ? Icons.save : Icons.check_circle,
            onPressed: () {
              context.read<PrayerBloc>().add(
                    UpdateNotificationSettings(
                      reminderMinutes: _minutes,
                      reminderIsBefore: _isBefore,
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ Reminder set: $_minutes mins ${_isBefore ? "before" : "after"} each prayer'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Notification row with icon, title, subtitle, and toggle.
class _NotificationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBorder;

  const _NotificationRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: AppColors.border, width: 2),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          NeoToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
