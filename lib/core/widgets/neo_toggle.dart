import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// A Neo-brutalist toggle switch matching the profile page CSS.
///
/// Replicates the custom toggle from profile.html:
/// - Width: 64px, Height: 36px
/// - Border: 2px solid border
/// - Knob: 28px circle with border
/// - Active: background-color changes to jamaat (#4ECDC4)
/// - Inactive: background-color changes to error (red)
class NeoToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const NeoToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final effectiveActiveColor = activeColor ?? c.jamaat;
    final inactiveColor = c.error;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged?.call(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 36,
        decoration: BoxDecoration(
          color: value ? effectiveActiveColor : inactiveColor,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: c.border,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: c.border,
              offset: const Offset(2, 2),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: c.border,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
