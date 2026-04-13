import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';

class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
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
                  color: AppColors.of(context).surface,
                  border: Border.all(color: AppColors.of(context).border, width: 3),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.of(context).border,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.local_fire_department, size: 80, color: AppColors.of(context).streak),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Build Your Streak',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Stay consistent. Log all 5 prayers daily to keep your flame alive.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.of(context).textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: NeoButton(
                  text: 'Let\'s Go',
                  color: AppColors.of(context).primary,
                  onPressed: () => context.go('/signup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
