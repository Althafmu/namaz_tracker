import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/services/time_service.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';

class FalahStreakCard extends StatelessWidget {
  final int streak;

  const FalahStreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "I'm on a",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B3D2E),
                      ),
                    ),
                    Text(
                      "$streak",
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: Color(0xFF0B3D2E),
                        height: 1,
                      ),
                    ),
                    const Text(
                      "day prayer\nstreak",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0B3D2E),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 140,
                height: 140,
                child: SvgPicture.asset(
                  "assets/falah_logo.svg",
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFF0B3D2E))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Color(0xFFF4A825),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFF0B3D2E))),
            ],
          ),
          const SizedBox(height: 4),
          _QuoteSection(),
          const SizedBox(height: 8),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/app_icon.png",
                  height: 38,
                  width: 38,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Falah",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0B3D2E),
                    ),
                  ),
                  Text(
                    "Prayer Tracker",
                    style: TextStyle(fontSize: 11, color: Color(0xFFF4A825)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteSection extends StatelessWidget {
  const _QuoteSection();

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
      source: 'Sahih al-Bukhari',
    ),
    _ReminderQuote(
      text:
          'Do not despair of Allah\'s mercy. Indeed, Allah forgives all sins.',
      source: 'Quran 39:53',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final today = TimeService.effectiveNow();
    final index =
        today.difference(DateTime(2024, 1, 1)).inDays % _quotes.length;
    final quote = _quotes[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${quote.text}"',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            height: 1.35,
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        const SizedBox(height: 4),
        Text(
          '— ${quote.source}',
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFF4A825),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ReminderQuote {
  final String text;
  final String source;

  const _ReminderQuote({required this.text, required this.source});
}
