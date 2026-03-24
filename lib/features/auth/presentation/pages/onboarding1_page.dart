import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';

class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Placeholder for the illustration
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border, width: 3),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.star, size: 80, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Set Your Intention',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Track your 5 daily prayers to build a consistent habit. Never miss a Jama\'at again.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: NeoButton(
                  text: 'Continue',
                  color: AppColors.primary,
                  onPressed: () => context.go('/onboarding2'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
