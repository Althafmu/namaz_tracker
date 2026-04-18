import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/settings/settings_event.dart';
import '../../../bloc/settings/settings_state.dart';
import '../../../bloc/streak/streak_bloc.dart';
import '../../../bloc/streak/streak_state.dart';

/// Yellow streak banner: "12 Day Streak!"
/// Uses StreakBloc to get the current streak value.
/// Sprint 1 (Phase 3 PRD): Shows protector token count + weekly tokens remaining.
class StreakHeader extends StatelessWidget {
  const StreakHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        final streak = state.streak.displayStreak;
        final tokens = state.streak.protectorTokens;
        final maxTokens = state.streak.maxProtectorTokens;
        final weeklyRemaining = state.streak.weeklyTokensRemaining;
        final weeklyLimit = state.streak.weeklyTokenLimit;
        final weeklyUsed = state.streak.weeklyTokensUsed;
        final weeklyLimitReached = state.streak.weeklyLimitReached;

        // Dispatch streak history update on load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GetIt.I<SettingsBloc>().add(UpdateStreakHistory(streak));
        });

        // Get last streak from SettingsState for soft landing
        final settingsState = GetIt.I<SettingsBloc>().state;
        final lastStreak = settingsState.lastStreak;
        final showSoftLanding = streak == 0 && lastStreak > 0;

        return NeoCard(
          color: c.streak,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: c.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      showSoftLanding
                          ? 'Start again today. Stay consistent.'
                          : '$streak Day Streak!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineMedium.copyWith(
                        letterSpacing: 1.0,
                        color: const Color(0xFF2B2D42), // Always dark on yellow banner
                      ),
                    ),
                  ),
                ],
              ),
              if (tokens > 0 || weeklyUsed > 0) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (tokens > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield,
                              color: const Color(0xFF2B2D42),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$tokens/$maxTokens',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF2B2D42),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (weeklyUsed > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: weeklyLimitReached
                              ? Colors.red.withValues(alpha: 0.3)
                              : c.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              weeklyLimitReached ? Icons.lock : Icons.refresh,
                              color: const Color(0xFF2B2D42),
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$weeklyRemaining/$weeklyLimit',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF2B2D42),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
