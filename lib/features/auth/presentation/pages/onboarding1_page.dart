import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../../../prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../../prayer/presentation/bloc/settings/settings_event.dart';

/// Pre-auth onboarding: 3-page PageView showcasing features + notification
/// permission. Shown once between splash and signup/login.
class Onboarding1Page extends StatefulWidget {
  const Onboarding1Page({super.key});

  @override
  State<Onboarding1Page> createState() => _Onboarding1PageState();
}

class _Onboarding1PageState extends State<Onboarding1Page> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding({bool requestNotifications = false}) async {
    context.read<AuthBloc>().add(const OnboardingCompleted());

    if (requestNotifications) {
      final granted = await GetIt.I<NotificationService>().requestPermissions();
      if (!mounted) return;

      context.read<SettingsBloc>().add(
        UpdateGlobalNotificationSettings(notificationsPermitted: granted),
      );
    }

    if (!mounted) return;
    context.go('/signup');
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: TextButton(
                  onPressed: () => _completeOnboarding(),
                  child: Text(
                    'SKIP',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [
                  _FeaturePage(
                    icon: Icons.mosque_rounded,
                    title: 'Track Your Salah\nwith Intention',
                    verse:
                        '"Indeed, prayer has been decreed upon the believers at fixed times."',
                    verseRef: 'Quran 4:103',
                    description:
                        'Log each prayer in seconds. Build a streak that reflects your real journey — no shame, just honest progress.',
                  ),
                  _FeaturePage(
                    icon: Icons.alt_route_rounded,
                    title: 'Grow at\nYour Own Pace',
                    verse:
                        '"The most beloved deeds to Allah are those done consistently, even if small."',
                    verseRef: 'Sahih al-Bukhari 6464',
                    description:
                        'Choose Foundation, Strengthening, or Growth mode. Each path adjusts expectations so you can build without burning out.',
                  ),
                  _NotificationPage(),
                ],
              ),
            ),

            // Dots + Next/Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? c.primary : c.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: NeoButton(
                      text: _currentPage == 2 ? 'Get Started' : 'Next',
                      color: c.primary,
                      onPressed: _currentPage == 2
                          ? () =>
                                _completeOnboarding(requestNotifications: true)
                          : _nextPage,
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
// Feature highlight page (pages 1 & 2)
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String verse;
  final String verseRef;
  final String description;

  const _FeaturePage({
    required this.icon,
    required this.title,
    required this.verse,
    required this.verseRef,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = constraints.maxHeight < 560 ? 80.0 : 110.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                AnimatedOnboardingIcon(icon: icon, size: iconSize),
                const SizedBox(height: 32),

                // Title
                Text(
                  title,
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Quran / Hadith quote
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.border, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        verse,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: c.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— $verseRef',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: c.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification permission page (page 3)
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationPage extends StatelessWidget {
  const _NotificationPage();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = constraints.maxHeight < 560 ? 80.0 : 110.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                AnimatedOnboardingIcon(
                  icon: Icons.notifications_active_rounded,
                  size: iconSize,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Never Miss\na Prayer',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Value prop
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.border, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '"Whoever is consistent in their five daily prayers, they will be a light and a proof and a salvation on the Day of Resurrection."',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: c.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— Musnad Ahmad 6576',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'Prayer-time alerts and a nightly 10 PM reminder can start once you allow notifications. Alarm-style reminder sounds stay off unless you enable Prayer Reminder or Streak Protection later in Settings.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: c.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedOnboardingIcon extends StatefulWidget {
  final IconData icon;
  final double size;

  const AnimatedOnboardingIcon({
    super.key,
    required this.icon,
    required this.size,
  });

  @override
  State<AnimatedOnboardingIcon> createState() => _AnimatedOnboardingIconState();
}

class _AnimatedOnboardingIconState extends State<AnimatedOnboardingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating Star Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _OnboardingStarPainter(
                    color: c.primaryLight,
                    borderColor: c.border,
                  ),
                ),
              );
            },
          ),
          // Static Icon in Center
          Icon(
            widget.icon,
            size: widget.size * 0.42,
            color: c.primary,
          ),
        ],
      ),
    );
  }
}

class _OnboardingStarPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _OnboardingStarPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.2;
    
    final path = Path();
    final int points = 16;
    final double outerR = radius;
    final double innerR = radius * 0.7653; 

    for (int i = 0; i < points; i++) {
      final double angle = i * pi / 8;
      final double r = (i % 2 == 0) ? outerR : innerR;
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final shadowPaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw shadow first
    canvas.drawPath(path.shift(const Offset(3, 3)), shadowPaint);
    // Draw fill
    canvas.drawPath(path, fillPaint);
    // Draw border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _OnboardingStarPainter oldDelegate) => false;
}
