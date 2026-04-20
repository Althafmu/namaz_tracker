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

  Future<void> _finishOnboarding() async {
    context.read<AuthBloc>().add(const OnboardingCompleted());

    final granted = await GetIt.I<NotificationService>().requestPermissions();
    if (!mounted) return;

    context.read<SettingsBloc>().add(
      UpdateGlobalNotificationSettings(notificationsPermitted: granted),
    );
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
                  onPressed: _finishOnboarding,
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
                          ? _finishOnboarding
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
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: c.primaryLight,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: c.border, width: 3),
                  ),
                  child: Icon(icon, size: iconSize * 0.5, color: c.primary),
                ),
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
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: c.primaryLight,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: c.border, width: 3),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: iconSize * 0.5,
                    color: c.primary,
                  ),
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
                  'Get gentle reminders at each prayer time. You can customise which prayers notify you later in Settings.',
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
