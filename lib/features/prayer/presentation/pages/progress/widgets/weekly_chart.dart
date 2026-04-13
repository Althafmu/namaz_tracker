import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';

/// Weekly bar chart — driven by real data.
/// (Currently commented out in the progress page but kept for future use.)
class WeeklyChart extends StatelessWidget {
  final List<double> percentages;
  final List<String> dayLabels;
  final int totalPrayers;

  const WeeklyChart({
    super.key,
    required this.percentages,
    required this.dayLabels,
    required this.totalPrayers,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    
    return NeoCard(
      color: c.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week', 
                style: AppTextStyles.bodyLarge.copyWith(color: c.textPrimary),
              ),
              Text(
                '$totalPrayers/35 Prayers',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 128,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isToday = index == 6;
                final pct = percentages.length > index
                    ? percentages[index]
                    : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.background,
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(
                                color: c.borderPrimary.withValues(alpha: 0.1),
                                width: 2,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: pct.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? c.streak
                                        : c.primary,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabels.length > index ? dayLabels[index] : '',
                          style: AppTextStyles.badge.copyWith(
                            color: isToday
                                ? c.textPrimary
                                : c.textSecondary,
                            fontWeight: isToday ? FontWeight.w900 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
