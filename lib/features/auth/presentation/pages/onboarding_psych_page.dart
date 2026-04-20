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
      icon: Icons.touch_app_rounded,
      title: 'Log each salah\nwithout friction',
      subtitle:
          'Tap a prayer card from Home, choose the status that matches your day, and keep your dashboard honest.',
      highlights: ['Daily logging from Home', 'Edit the last 2 days if needed'],
    ),
    _PsychSlide(
      icon: Icons.alt_route,
      title: 'Choose a path that\nfits your pace',
      subtitle:
          'Foundation keeps recovery gentle. Growth adds tighter expectations and optional Sunnah practice.',
      highlights: ['Change your path later', 'Growth unlocks Sunnah tracking'],
    ),
    _PsychSlide(
      icon: Icons.event_busy,
      title: 'Use excused mode\nonly when needed',
      subtitle:
          'Travel, sickness, or period can freeze a day without breaking your streak. If your day changes, you can resume logging.',
      highlights: [
        'Streak stays preserved',
        'Notifications pause for excused days',
      ],
    ),
    _PsychSlide(
      icon: Icons.notifications_active_outlined,
      title: 'Set preferences\nfrom day one',
      subtitle:
          'We will ask for reminder permission next. Later you can fine-tune prayer times, themes, and optional tracking from Profile.',
      highlights: [
        'Reminder permission comes next',
        'Profile holds the rest of your settings',
      ],
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
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
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
                      color: _currentPage == index ? c.primary : c.border,
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
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final iconBoxSize = constraints.maxHeight < 560
                          ? 96.0
                          : 120.0;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: iconBoxSize,
                                height: iconBoxSize,
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  border: Border.all(color: c.border, width: 3),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  slide.icon,
                                  size: iconBoxSize * 0.5,
                                  color: c.primary,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                slide.title,
                                style: AppTextStyles.headlineLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                slide.subtitle,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: c.textPrimary,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: slide.highlights
                                    .map(
                                      (highlight) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: c.surface,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: c.border,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          highlight,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: c.textPrimary,
                                                fontWeight: FontWeight.w700,
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
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          height: 48,
                          child: NeoButton(
                            text: 'Next',
                            color: c.primary,
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
                style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
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
  final List<String> highlights;

  const _PsychSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlights,
  });
}
