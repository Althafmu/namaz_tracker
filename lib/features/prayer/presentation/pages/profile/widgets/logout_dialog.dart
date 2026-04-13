import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_event.dart';

/// Shows the logout confirmation dialog.
void showLogoutDialog(BuildContext context) {
  final c = AppColors.of(context);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: c.border, width: 2),
      ),
      title: Text('Log Out', style: AppTextStyles.headlineMedium.copyWith(
        color: c.textPrimary,
      )),
      content: Text(
        'Are you sure you want to log out? Your locally-saved data will be preserved.',
        style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
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
          text: 'Log Out',
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
