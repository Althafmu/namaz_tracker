import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/settings/settings_event.dart';
import '../../../bloc/settings/settings_state.dart';

/// Shows the Theme Selection bottom sheet.
void showThemeSelectionSheet(BuildContext context) {
  final c = AppColors.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: c.surface,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: c.border, width: 2),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(sheetContext).viewPadding.bottom + 24,
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
                  color: c.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('App Theme', style: AppTextStyles.headlineMedium.copyWith(
              color: c.textPrimary,
            )),
            const SizedBox(height: 24),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _ThemeOptionTile(
                      title: 'System Default',
                      icon: Icons.brightness_auto,
                      isSelected: state.themeMode == 'system',
                      onTap: () {
                        context.read<SettingsBloc>().add(const UpdateThemeMode('system'));
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const SizedBox(height: 12),
                    _ThemeOptionTile(
                      title: 'Light Mode',
                      icon: Icons.light_mode,
                      isSelected: state.themeMode == 'light',
                      onTap: () {
                        context.read<SettingsBloc>().add(const UpdateThemeMode('light'));
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    const SizedBox(height: 12),
                    _ThemeOptionTile(
                      title: 'Dark Mode',
                      icon: Icons.dark_mode,
                      isSelected: state.themeMode == 'dark',
                      onTap: () {
                        context.read<SettingsBloc>().add(const UpdateThemeMode('dark'));
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? c.primaryLight : c.background,
          border: Border.all(
            color: isSelected ? c.primary : c.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? c.primary : c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? c.primary : c.border),
              ),
              child: Icon(
                icon,
                color: isSelected ? c.surface : c.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: c.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: c.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
