import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../../../../core/utils/streak_card_share_util.dart';
import 'falah_streak_card.dart';

class ShareStreakModal extends StatefulWidget {
  final int streakCount;

  const ShareStreakModal({super.key, required this.streakCount});

  static Future<void> show(BuildContext context, {required int streakCount}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => ShareStreakModal(streakCount: streakCount),
    );
  }

  @override
  State<ShareStreakModal> createState() => _ShareStreakModalState();
}

class _ShareStreakModalState extends State<ShareStreakModal> {
  final GlobalKey _modalCardKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _handleShare() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);

    try {
      final bytes = await StreakCardShareUtil.captureCard(_modalCardKey);
      if (bytes != null) {
        await StreakCardShareUtil.shareCard(bytes, widget.streakCount);
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.75,
      child: Container(
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Your Streak',
              style: AppTextStyles.headlineMedium.copyWith(
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth.clamp(0.0, 360.0);
                      final cardWidth = maxWidth;
                      final cardHeight = cardWidth * 5 / 4;
                      return SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: RepaintBoundary(
                          key: _modalCardKey,
                          child: FalahStreakCard(streak: widget.streakCount),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            NeoCard(
              color: c.primary,
              onTap: _isSharing ? null : _handleShare,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Center(
                  child: _isSharing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: c.primary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share, color: c.onAccent, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Share Card',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: c.onAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
