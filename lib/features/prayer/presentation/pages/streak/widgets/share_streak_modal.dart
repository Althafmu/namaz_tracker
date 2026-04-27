import 'package:flutter/material.dart';
import '../../../../../../core/utils/streak_card_share_util.dart';
import 'falah_streak_card.dart';

class ShareStreakModal extends StatefulWidget {
  final int streakCount;

  const ShareStreakModal({
    super.key,
    required this.streakCount,
  });

  static Future<void> show(BuildContext context, {required int streakCount}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.75,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B3D2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share Your Streak',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  color: const Color(0xFF0B3D2E),
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: RepaintBoundary(
                      key: _modalCardKey,
                      child: FalahStreakCard(streak: widget.streakCount),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSharing ? null : _handleShare,
                icon: _isSharing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0B3D2E),
                        ),
                      )
                    : const Icon(Icons.share, color: Color(0xFF0B3D2E)),
                label: Text(
                  _isSharing ? 'Sharing...' : 'Share Card',
                  style: const TextStyle(
                    color: Color(0xFF0B3D2E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}