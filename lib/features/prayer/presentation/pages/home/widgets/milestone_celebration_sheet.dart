import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_button.dart';
import '../../../../../../core/widgets/confetti_particles_widget.dart';

class MilestoneCelebrationBottomSheet extends StatefulWidget {
  final int milestone;
  final String message;

  const MilestoneCelebrationBottomSheet({
    super.key,
    required this.milestone,
    required this.message,
  });

  static Future<void> show(BuildContext context, int milestone, String message) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => MilestoneCelebrationBottomSheet(
        milestone: milestone,
        message: message,
      ),
    );
  }

  @override
  State<MilestoneCelebrationBottomSheet> createState() =>
      _MilestoneCelebrationBottomSheetState();
}

class _MilestoneCelebrationBottomSheetState
    extends State<MilestoneCelebrationBottomSheet>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _entryController;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.elasticOut,
      ),
    );

    _entryController.forward();

    // Trigger confetti burst slightly after sheet opens to allow visual entry first
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _confettiController.burst();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Bouncy sheet entry
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * 300),
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.border, width: 3),
              boxShadow: [
                BoxShadow(
                  color: c.border,
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star Icon / Ribbon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59), // Bright yellow
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: c.border,
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Color(0xFF2B2D42),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                // Streak Badge/Title
                Text(
                  '${widget.milestone} Day Streak!',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: c.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle / Milestone Text
                Text(
                  'SPIRITUAL MILESTONE',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Spiritual Message Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.border, width: 2),
                  ),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textPrimary,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Alhamdulillah Action Button
                SizedBox(
                  width: double.infinity,
                  child: NeoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Alhamdulillah',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Confetti explosion overlay
        Positioned.fill(
          child: IgnorePointer(
            child: ConfettiParticlesWidget(controller: _confettiController),
          ),
        ),
      ],
    );
  }
}
