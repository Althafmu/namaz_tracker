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
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        color: isActive ? c.jamaat : c.surface,
        borderRadius: 9999,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.group,
                    color: isActive ? const Color(0xFF2B2D42) : c.textPrimary,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Prayed in Jama'at",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isActive ? const Color(0xFF2B2D42) : c.textPrimary,
                      ),
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
                      color: c.streak,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: c.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: c.border,
                          offset: const Offset(2, 2),
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
                    color: isActive ? c.textPrimary : c.textSecondary,
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
                      decoration: BoxDecoration(
                        color: c.surface,
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
