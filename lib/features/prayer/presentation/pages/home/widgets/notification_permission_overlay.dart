import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:namaz_tracker/core/services/notification_service.dart';
import 'package:namaz_tracker/core/theme/app_colors.dart';
import 'package:namaz_tracker/core/theme/app_text_styles.dart';
import 'package:namaz_tracker/core/widgets/neo_button.dart';
import 'package:namaz_tracker/features/prayer/presentation/bloc/settings/settings_bloc.dart';
import 'package:namaz_tracker/features/prayer/presentation/bloc/settings/settings_event.dart';

/// Neo-styled overlay shown once after login to explain and request
/// notification permissions for returning users.
class NotificationPermissionOverlay extends StatelessWidget {
  const NotificationPermissionOverlay({super.key});

  /// Shows the overlay as a modal dialog. Returns `true` if permission was
  /// granted, `false` otherwise.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NotificationPermissionOverlay(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border, width: 2),
          boxShadow: [BoxShadow(color: c.border, offset: const Offset(4, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: c.border, width: 2),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                size: 32,
                color: c.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Stay on track',
              style: AppTextStyles.headlineMedium.copyWith(
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Hadith context
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.jamaatLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.jamaat.withValues(alpha: 0.3)),
              ),
              child: Text(
                '"The first matter that the slave will be brought to account for on the Day of Judgement is the prayer."\n— Sunan an-Nasa\'i',
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textPrimary,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Explanation
            Text(
              'Falah needs notification permission to send prayer-time alerts and a nightly 10 PM reminder. Alarm-style reminder sounds stay off unless you enable Prayer Reminder or Streak Protection in Settings.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            NeoButton(
              text: 'Allow Notifications',
              icon: Icons.notifications_active,
              onPressed: () async {
                final granted = await GetIt.I<NotificationService>()
                    .requestPermissions();
                GetIt.I<SettingsBloc>().add(
                  UpdateGlobalNotificationSettings(
                    notificationsPermitted: granted,
                  ),
                );
                if (context.mounted) Navigator.of(context).pop(granted);
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Not Now',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
