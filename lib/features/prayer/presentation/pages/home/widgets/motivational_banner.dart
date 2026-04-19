import 'package:flutter/material.dart';

import '../../../../../../core/services/time_service.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';

/// Motivational quote banner.
class MotivationalBanner extends StatelessWidget {
  const MotivationalBanner({super.key});

  static const List<_ReminderQuote> _quotes = [
    _ReminderQuote(
      text: 'Establish prayer for My remembrance.',
      source: 'Quran 20:14',
    ),
    _ReminderQuote(
      text:
          'Seek help through patience and prayer. Indeed, Allah is with the steadfast.',
      source: 'Quran 2:153',
    ),
    _ReminderQuote(
      text:
          'The five daily prayers are expiation for what is between them, so long as major sins are avoided.',
      source: 'Sahih Muslim',
    ),
    _ReminderQuote(
      text:
          'The most beloved deeds to Allah are those done consistently, even if they are small.',
      source: 'Sahih al-Bukhari and Sahih Muslim',
    ),
    _ReminderQuote(
      text:
          'Do not despair of Allah\'s mercy. Indeed, Allah forgives all sins.',
      source: 'Quran 39:53',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final today = TimeService.effectiveNow();
    final index =
        today.difference(DateTime(2024, 1, 1)).inDays % _quotes.length;
    final quote = _quotes[index];

    return NeoCard(
      color: c.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Reminder',
            style: AppTextStyles.sectionHeader.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u201C\u201C',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: c.primary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quote.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote.source,
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderQuote {
  final String text;
  final String source;

  const _ReminderQuote({required this.text, required this.source});
}
