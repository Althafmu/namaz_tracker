import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../bloc/streak/streak_bloc.dart';
import '../../../bloc/streak/streak_state.dart';

/// Yellow streak banner: "12 Day Streak!"
/// Uses StreakBloc to get the current streak value.
class StreakHeader extends StatelessWidget {
  const StreakHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        final streak = state.streak.displayStreak;
        return NeoCard(
          color: c.streak,
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: c.primary,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Text(
                  '$streak Day Streak!',
                  style: AppTextStyles.headlineMedium.copyWith(
                    letterSpacing: 1.5,
                    color: const Color(0xFF2B2D42), // Always dark on yellow banner
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
