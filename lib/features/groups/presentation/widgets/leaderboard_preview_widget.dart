import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_card.dart';
import '../../data/models/group_dashboard_model.dart';

class LeaderboardPreviewWidget extends StatelessWidget {
  final List<LeaderboardEntry> streaks;
  final String? currentUserName;
  final int? currentUserRank;
  final int? currentUserStreak;
  final int memberCount;

  const LeaderboardPreviewWidget({
    super.key,
    required this.streaks,
    this.currentUserName,
    this.currentUserRank,
    this.currentUserStreak,
    this.memberCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final displayEntries = streaks.take(5).toList();
    final currentUserInTop5 = displayEntries.any(
      (e) => e.username == currentUserName,
    );

    final entriesWithCurrentUser = [
      ...displayEntries.map((e) => e.copyWith(
            isCurrentUser: e.username == currentUserName,
          )),
    ];

    if (!currentUserInTop5 && currentUserName != null) {
      entriesWithCurrentUser.add(
        LeaderboardEntry(
          rank: currentUserRank ?? displayEntries.length + 1,
          username: currentUserName!,
          streak: currentUserStreak ?? 0,
          isCurrentUser: true,
        ),
      );
    }

    return NeoCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LEADERBOARD',
                  style: AppTextStyles.sectionHeader.copyWith(color: c.textPrimary),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showFullLeaderboard(context);
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'View All',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entriesWithCurrentUser.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      memberCount <= 1
                          ? 'Invite friends to make this group active'
                          : 'No streaks yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    if (memberCount > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Complete prayers to appear on the leaderboard',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
              ...entriesWithCurrentUser.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                if (index >= 5 && !item.isCurrentUser) return const SizedBox.shrink();
                return _LeaderboardRow(entry: item);
              }),
          ],
        ),
      ),
    );
  }

  void _showFullLeaderboard(BuildContext context) {
    final c = AppColors.of(context);
    final currentUserInList = streaks.any((e) => e.username == currentUserName);
    final allEntries = streaks.map((e) => e.copyWith(
          isCurrentUser: e.username == currentUserName,
        )).toList();

    if (!currentUserInList && currentUserName != null) {
      allEntries.add(
        LeaderboardEntry(
          rank: currentUserRank ?? (streaks.isNotEmpty ? streaks.last.rank + 1 : 1),
          username: currentUserName!,
          streak: currentUserStreak ?? 0,
          isCurrentUser: true,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360,
                maxHeight: constraints.maxHeight * 0.8,
              ),
              child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: c.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'LEADERBOARD',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: c.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (allEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No entries yet',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: allEntries
                                .map((item) => _LeaderboardRow(entry: item))
                                .toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: NeoButton(
                        text: 'CLOSE',
                        color: c.surface,
                        textColor: c.textPrimary,
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    String? badge;
    if (entry.rank == 1) badge = '🥇';
    if (entry.rank == 2) badge = '🥈';
    if (entry.rank == 3) badge = '🥉';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? c.primary.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: badge != null
                ? Text(badge, style: const TextStyle(fontSize: 18))
                : Text(
                    '#${entry.rank}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontWeight: entry.isCurrentUser ? FontWeight.bold : null,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.isCurrentUser ? '${entry.username} (You)' : entry.username,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: entry.isCurrentUser ? c.primary : c.textPrimary,
              ),
            ),
          ),
          Row(
            children: [
              if (entry.streak > 0) ...[
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Text(
                '${entry.streak}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: entry.isCurrentUser ? c.primary : c.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}