import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_event.dart';

/// Shows the delete account confirmation dialog.
void showDeleteAccountDialog(BuildContext context) {
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
