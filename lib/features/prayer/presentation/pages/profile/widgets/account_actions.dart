import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';

/// Account action buttons — "Log Out" and "Delete Account".
class AccountActions extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const AccountActions({
    super.key,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      children: [
        NeoButton(
          text: 'Log Out',
          icon: Icons.logout,
          onPressed: onLogout,
        ),
        const SizedBox(height: 16),
        // Delete account button
        GestureDetector(
          onTap: onDeleteAccount,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: c.textSecondary,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                'Delete Account',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
