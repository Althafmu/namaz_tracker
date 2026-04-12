import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../../../../core/widgets/neo_text_field.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows the "Edit Profile" bottom sheet.
void showEditProfileSheet(BuildContext context) {
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
