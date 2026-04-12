import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Location selector button (Mosque / Home / Work).
class LocationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const LocationButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(
            isSelected ? 2.0 : 0.0,
            isSelected ? 2.0 : 0.0,
            0.0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.streak : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.border,
                offset: Offset(isSelected ? 0.0 : 4.0, isSelected ? 0.0 : 4.0),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.textDark, size: 24),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
