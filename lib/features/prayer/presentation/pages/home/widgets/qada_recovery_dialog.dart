import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../bloc/streak/streak_bloc.dart';
import '../../../bloc/streak/streak_event.dart';
import '../../../bloc/streak/streak_state.dart';

/// Dialog that prompts users to consume a protector token to save their streak
/// after performing a Qada (makeup) prayer.
///
/// Phase 2: Streak Freeze System
class QadaRecoveryDialog extends StatelessWidget {
  /// The date for which the token should be consumed (optional, defaults to yesterday)
  final String? date;

  const QadaRecoveryDialog({super.key, this.date});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        final tokens = state.streak.protectorTokens;
        final maxTokens = state.streak.maxProtectorTokens;
        final weeklyLimitReached = state.streak.weeklyLimitReached;

        // Sprint 1: Button is disabled if no tokens OR weekly limit reached
        final canUseToken = tokens > 0 && !weeklyLimitReached;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border, width: 2),
              boxShadow: [
                BoxShadow(
                  color: c.border,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.streak.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield,
                    size: 48,
                    color: c.streak,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Title ──
                Text(
                  'Save Your Streak?',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: c.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // ── Description ──
                Text(
                  'You completed a Qada prayer. Use a Protector Token to keep your streak intact?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // ── Token Counter ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.token,
                        color: tokens > 0 ? c.streak : c.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$tokens / $maxTokens Tokens',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: tokens > 0 ? c.textPrimary : c.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Action Buttons ──
                Row(
                  children: [
                    Expanded(
                      child: NeoButton(
                        text: 'Skip',
                        onPressed: () => Navigator.of(context).pop(false),
                        color: c.surface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeoButton(
                        text: 'Use Token',
                        icon: Icons.check,
                        onPressed: canUseToken
                            ? () => _useToken(context)
                            : null,
                        color: c.streak,
                      ),
                    ),
                  ],
                ),

                // ── Token Status Message (Sprint 1) ──
                if (tokens == 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'No tokens available. Tokens reset every Sunday.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: c.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else if (weeklyLimitReached) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Weekly recovery limit reached. Reset every Sunday.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.red.shade300,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _useToken(BuildContext context) {
    context.read<StreakBloc>().add(ConsumeProtectorToken(date: date));
    Navigator.of(context).pop(true);
  }

  /// Shows the Qada recovery dialog and returns true if token was used.
  static Future<bool?> show(BuildContext context, {String? date}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => QadaRecoveryDialog(date: date),
    );
  }
}