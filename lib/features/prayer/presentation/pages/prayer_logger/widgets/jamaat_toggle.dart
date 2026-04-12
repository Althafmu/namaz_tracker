import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';

/// Jama'at toggle button — rounded pill with teal background when active.
class JamaatToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const JamaatToggle({super.key, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        color: isActive ? AppColors.jamaat : AppColors.surface,
        borderRadius: 9999,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.group, color: AppColors.textDark, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Prayed in Jama'at",
                      style: AppTextStyles.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.streak,
                      borderRadius: BorderRadius.circular(9999),
                      border:
                          Border.all(color: AppColors.border, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.border,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text('+10XP', style: AppTextStyles.badge),
                  ),
                const SizedBox(width: 12),
                // Mini toggle
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.textDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: isActive
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
