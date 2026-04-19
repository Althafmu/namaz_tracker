import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_event.dart';

/// Shows the delete account confirmation dialog.
void showDeleteAccountDialog(BuildContext context) {
  final c = AppColors.of(context);
  final confirmController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.border, width: 2),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Delete Account',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action permanently deletes your account and all related prayer data. This cannot be undone.',
              style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Type DELETE to confirm:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              onChanged: (_) => setDialogState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: c.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyLarge.copyWith(color: c.textSecondary),
            ),
          ),
          NeoButton(
            text: 'Delete',
            color: confirmController.text == 'DELETE'
                ? Colors.redAccent
                : c.textSecondary,
            isFullWidth: false,
            height: 44,
            onPressed: confirmController.text == 'DELETE'
                ? () async {
                    Navigator.of(dialogContext).pop();
                    final authBloc = context.read<AuthBloc>();
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await authBloc.authRepository.deleteAccount();
                      if (!context.mounted) return;
                      // Reuse logout flow to clear local tokens and route state.
                      authBloc.add(LogoutRequested());
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Your account has been permanently deleted.',
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      final message = e.toString().replaceFirst(
                        'Exception: ',
                        '',
                      );
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            message.isEmpty
                                ? 'Failed to delete account. Please try again.'
                                : message,
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
    ),
  );
}
