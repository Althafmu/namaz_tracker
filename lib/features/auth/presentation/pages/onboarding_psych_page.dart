import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class OnboardingPsychPage extends StatefulWidget {
  const OnboardingPsychPage({super.key});

  @override
  State<OnboardingPsychPage> createState() => _OnboardingPsychPageState();
}

class _OnboardingPsychPageState extends State<OnboardingPsychPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_PsychSlide> _slides = [
    _PsychSlide(
      icon: Icons.self_improvement,
      title: 'This app helps you stay\nconsistent with your prayers',
      subtitle: '',
    ),
    _PsychSlide(
      icon: Icons.favorite,
      title: 'Consistency matters\nmore than perfection',
      subtitle: '',
    ),
    _PsychSlide(
      icon: Icons.replay,
      title: 'If you miss occasionally,\nyou still have a chance to make it right',
      subtitle: '',
    ),
    _PsychSlide(
      icon: Icons.play_arrow,
      title: 'Start today.\nOne prayer at a time.',
      subtitle: '',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                    padding: const EdgeInsets.all(48.0),
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
                        onPressed: () {
                          context.read<AuthBloc>().add(const OnboardingCompleted());
                          context.go('/signup');
                        },
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(const OnboardingCompleted());
                            context.go('/signup');
                          },
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

  const _PsychSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}