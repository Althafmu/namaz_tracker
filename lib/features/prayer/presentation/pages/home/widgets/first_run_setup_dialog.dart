import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// A modal overlay shown on the user's first Home visit.
///
/// Renders a small card (not full-screen) on top of the real Home page,
/// backed by a semi-transparent scrim. Contains a 2-card PageView with
/// contextual tips: (1) how to log a prayer, (2) excused mode.
class FirstRunSetupDialog extends StatefulWidget {
  const FirstRunSetupDialog({super.key});

  @override
  State<FirstRunSetupDialog> createState() => _FirstRunSetupDialogState();
}

class _FirstRunSetupDialogState extends State<FirstRunSetupDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _cards = [
    _TipCard(
      icon: Icons.touch_app_rounded,
      title: 'Tap to log your prayer',
      body:
          'Tap any prayer card on this screen, choose your status (Done, Missed, Qada…), and your day updates instantly.',
      highlights: ['Quick — takes 2 seconds', 'Edit the last 2 days anytime'],
    ),
    _TipCard(
      icon: Icons.nightlight_round,
      title: 'Having a tough day?',
      body:
          'Use excused mode when you\'re travelling, unwell, or on your period. Your streak stays safe, and you can resume logging later.',
      highlights: ['Streak preserved', 'Notifications pause automatically'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final compactWidth = screenSize.width < 360;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compactWidth ? 16 : 20,
        vertical: compactWidth ? 20 : 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 360,
          maxHeight: screenSize.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.border, width: 3),
          boxShadow: [BoxShadow(color: c.border, offset: const Offset(4, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // PageView of tip cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) => _cards[index],
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(_cards.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? c.primary : c.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // Next / Got it button
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: c.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage < _cards.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      _currentPage < _cards.length - 1 ? 'Next' : 'Got it',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual tip card rendered inside the PageView
// ─────────────────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final List<String> highlights;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 340 || constraints.maxHeight < 520;
        final iconSize = compact ? 44.0 : 52.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 20,
            compact ? 12 : 16,
            compact ? 16 : 20,
            8,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon circle
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: c.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border, width: 2),
                  ),
                  child: Icon(icon, size: compact ? 20 : 24, color: c.primary),
                ),
                SizedBox(height: compact ? 10 : 14),

                // Title
                Text(
                  title,
                  style:
                      (compact
                              ? AppTextStyles.headlineSmall
                              : AppTextStyles.headlineMedium)
                          .copyWith(color: c.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Body
                Text(
                  body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: compact ? 12 : 16),

                // Highlight chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: highlights
                      .map(
                        (h) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 10 : 12,
                            vertical: compact ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: c.primaryLight,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: c.border, width: 1.5),
                          ),
                          child: Text(
                            h,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
