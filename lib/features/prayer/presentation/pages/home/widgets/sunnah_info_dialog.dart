import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

void showSunnahInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const SunnahInfoDialog(),
  );
}

class SunnahInfoDialog extends StatelessWidget {
  const SunnahInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Dialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: c.jamaat, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Extra Prayers (Sunnah)',
                  style: AppTextStyles.headlineMedium.copyWith(color: c.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(c, 'Rawatib', 'Sunnah prayers performed before/after Fard (obligatory) prayers.'),
            const SizedBox(height: 12),
            _buildInfoRow(c, 'Witr', 'An odd-numbered prayer performed after Isha, concluding the night prayers.'),
            const SizedBox(height: 12),
            _buildInfoRow(c, 'Dhuha', 'The forenoon prayer, performed after sunrise and before Dhuhr.'),
            const SizedBox(height: 12),
            _buildInfoRow(c, 'Tahajjud', 'The voluntary night prayer, performed after sleeping and waking up before Fajr.'),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Got it',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(AppColorPalette c, String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}
