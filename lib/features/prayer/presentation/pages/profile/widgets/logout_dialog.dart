import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_event.dart';

/// Shows the logout confirmation dialog.
void showLogoutDialog(BuildContext context) {
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
