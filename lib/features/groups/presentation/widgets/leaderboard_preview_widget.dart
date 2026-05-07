import 'package:flutter/material.dart';
import '../../data/models/group_dashboard_model.dart';

class LeaderboardPreviewWidget extends StatelessWidget {
  final List<LeaderboardEntry> streaks;
  final int? currentUserId;
  final String? currentUserName;

  const LeaderboardPreviewWidget({
    super.key,
    required this.streaks,
    this.currentUserId,
    this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
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
          rank: displayEntries.length + 1,
          username: currentUserName!,
          streak: 0,
          isCurrentUser: true,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Leaderboard',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'View All',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entriesWithCurrentUser.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No streaks yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              )
            else
              ...entriesWithCurrentUser.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                if (index >= 5) return const SizedBox.shrink();
                return _LeaderboardRow(
                  rank: index + 1,
                  username: item.username,
                  streak: item.streak,
                  isCurrentUser: item.isCurrentUser,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String username;
  final int streak;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.username,
    required this.streak,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    String? badge;
    if (rank == 1) badge = '🥇';
    if (rank == 2) badge = '🥈';
    if (rank == 3) badge = '🥉';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: badge != null
                ? Text(badge, style: const TextStyle(fontSize: 18))
                : Text(
                    '#$rank',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCurrentUser ? '$username (You)' : username,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrentUser ? FontWeight.bold : null,
                    color: isCurrentUser
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
          ),
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}