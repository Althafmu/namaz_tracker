import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../bloc/settings/settings_bloc.dart';
import '../../../bloc/settings/settings_event.dart';
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
    final lastStreak = context.select<SettingsBloc, int>(
      (bloc) => bloc.state.lastStreak,
    );

    return BlocListener<StreakBloc, StreakState>(
      listenWhen: (previous, current) =>
          previous.streak.displayStreak != current.streak.displayStreak,
      listener: (context, state) {
        GetIt.I<SettingsBloc>().add(
          UpdateStreakHistory(state.streak.displayStreak),
        );
      },
      child: BlocBuilder<StreakBloc, StreakState>(
        builder: (context, state) {
          final streak = state.streak.displayStreak;
          final tokens = state.streak.protectorTokens;
          final maxTokens = state.streak.maxProtectorTokens;
          final weeklyRemaining = state.streak.weeklyTokensRemaining;
          final weeklyLimit = state.streak.weeklyTokenLimit;
          final weeklyUsed = state.streak.weeklyTokensUsed;
          final weeklyLimitReached = state.streak.weeklyLimitReached;
          final showSoftLanding = streak == 0 && lastStreak > 0;

          return NeoCard(
            color: c.streak,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PulsatingFireIcon(
                      color: c.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          );
                          return ScaleTransition(
                            scale: scaleAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          showSoftLanding
                              ? 'Start again today. Stay consistent.'
                              : '$streak Day Streak!',
                          key: ValueKey<String>(
                            showSoftLanding ? 'soft_landing' : '${streak}_streak',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineMedium.copyWith(
                            letterSpacing: 1.0,
                            color: const Color(
                              0xFF2B2D42,
                            ), // Always dark on yellow banner
                          ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}

class PulsatingFireIcon extends StatefulWidget {
  final double size;
  final Color color;

  const PulsatingFireIcon({
    super.key,
    this.size = 32,
    required this.color,
  });

  @override
  State<PulsatingFireIcon> createState() => _PulsatingFireIconState();
}

class _PulsatingFireIconState extends State<PulsatingFireIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _FirePainter(
            animationValue: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _FirePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _FirePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final shadowPaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.fill;

    final flicker = sin(animationValue * pi * 2) * 1.5;
    final flickerY = cos(animationValue * pi * 2) * 1.0;

    final shadowPath = _buildFlamePath(w, h, flicker, flickerY, offset: const Offset(2, 2));
    canvas.drawPath(shadowPath, shadowPaint);

    final outerPath = _buildFlamePath(w, h, flicker, flickerY);
    canvas.drawPath(outerPath, outerPaint);
    canvas.drawPath(outerPath, borderPaint);

    final innerPaint = Paint()
      ..color = const Color(0xFFFFDE59)
      ..style = PaintingStyle.fill;
    final innerPath = _buildFlamePath(w * 0.6, h * 0.6, -flicker * 0.8, -flickerY * 0.8, offset: Offset(w * 0.2, h * 0.35));
    canvas.drawPath(innerPath, innerPaint);
    canvas.drawPath(innerPath, borderPaint..strokeWidth = 1.5);
  }

  Path _buildFlamePath(double w, double h, double fx, double fy, {Offset offset = Offset.zero}) {
    final path = Path();
    final ox = offset.dx;
    final oy = offset.dy;

    path.moveTo(ox + w * 0.5, oy + h);
    path.cubicTo(
      ox + w * 0.1 + fx, oy + h * 0.9,
      ox + w * 0.05 - fx, oy + h * 0.6 + fy,
      ox + w * 0.2 + fx, oy + h * 0.45
    );
    path.cubicTo(
      ox + w * 0.15 - fx, oy + h * 0.3 + fy,
      ox + w * 0.35 + fx, oy + h * 0.15,
      ox + w * 0.5, oy + h * 0.05 + fy
    );
    path.cubicTo(
      ox + w * 0.65 - fx, oy + h * 0.15,
      ox + w * 0.85 + fx, oy + h * 0.3 + fy,
      ox + w * 0.8 - fx, oy + h * 0.45
    );
    path.cubicTo(
      ox + w * 0.95 + fx, oy + h * 0.6 + fy,
      ox + w * 0.9 - fx, oy + h * 0.9,
      ox + w * 0.5, oy + h
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _FirePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}
