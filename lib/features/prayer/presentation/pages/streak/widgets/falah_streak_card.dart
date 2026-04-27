import 'package:flutter/material.dart';

class FalahStreakCard extends StatelessWidget {
  final int streak;

  const FalahStreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 440,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "I'm on a",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B3D2E),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    "$streak",
                    style: const TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Color(0xFF0B3D2E),
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    "day prayer\nstreak",
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0B3D2E),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: -30,
                child: SizedBox(
                  height: 170,
                  width: 220,
                  child: Image.asset(
                    "assets/falah_icon.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Color(0xFFF4A825),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 4),
          _QuoteSection(),
          const Spacer(),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/app_icon.png",
                  height: 44,
                  width: 44,
                  fit: BoxFit.cover,
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
                      fontSize: 16,
                      color: Color(0xFF0B3D2E),
                    ),
                  ),
                  Text(
                    "Prayer Tracker",
                    style: TextStyle(fontSize: 13, color: Color(0xFFF4A825)),
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
    final today = DateTime.now();
    final index =
        today.difference(DateTime(2024, 1, 1)).inDays % _quotes.length;
    final quote = _quotes[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${quote.text}"',
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          '— ${quote.source}',
          style: const TextStyle(
            fontSize: 13,
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
