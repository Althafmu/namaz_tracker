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

class OnboardingPsychPage extends StatefulWidget {
  const OnboardingPsychPage({super.key});

  @override
  State<OnboardingPsychPage> createState() => _OnboardingPsychPageState();
}

class _OnboardingPsychPageState extends State<OnboardingPsychPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_PsychSlide> _slides = const [
    _PsychSlide(
      icon: Icons.nightlight_round,
      title: 'Prayer anchors\nyour heart',
      subtitle: '"Establish prayer for My remembrance."',
      source: 'Quran 20:14',
    ),
    _PsychSlide(
      icon: Icons.favorite,
      title: 'Consistency is beloved\nto Allah',
      subtitle:
          '"The most beloved deeds to Allah are those done consistently, even if they are small."',
      source: 'Sahih al-Bukhari and Sahih Muslim',
    ),
    _PsychSlide(
      icon: Icons.water_drop_outlined,
      title: 'Every salah is a chance\nto be cleansed again',
      subtitle:
          '"The five daily prayers are expiation for what is between them, so long as major sins are avoided."',
      source: 'Sahih Muslim',
    ),
    _PsychSlide(
      icon: Icons.refresh_rounded,
      title: 'Mercy stays open\nafter a miss',
      subtitle:
          '"Do not despair of Allah\'s mercy. Indeed, Allah forgives all sins."',
      source: 'Quran 39:53',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboardingAndRequestNotifications() async {
    context.read<AuthBloc>().add(const OnboardingCompleted());

    final granted = await GetIt.I<NotificationService>().requestPermissions();
    if (!mounted) return;

    context.read<SettingsBloc>().add(
      UpdateGlobalNotificationSettings(notificationsPermitted: granted),
    );
    context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.of(context).primary
                          : AppColors.of(context).border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.of(context).surface,
                            border: Border.all(
                              color: AppColors.of(context).border,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: AppColors.of(context).primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide.title,
                          style: AppTextStyles.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          slide.subtitle,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.of(context).textPrimary,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.source,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.of(context).textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage == _slides.length - 1
                  ? SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: NeoButton(
                        text: 'Get Started',
                        color: AppColors.of(context).primary,
                        onPressed: _completeOnboardingAndRequestNotifications,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _completeOnboardingAndRequestNotifications,
                          child: Text(
                            'Skip',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.of(context).textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          height: 48,
                          child: NeoButton(
                            text: 'Next',
                            color: AppColors.of(context).primary,
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                'Next, we will ask for notification permission so prayer reminders can work from day one.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.of(context).textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PsychSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final String source;

  const _PsychSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.source,
  });
}
