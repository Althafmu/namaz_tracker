import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/neo_card.dart';
import '../../../bloc/prayer/prayer_state.dart';

/// Displays sync metadata in the progress page.
///
/// Shows the last sync status (syncing, synced, error) with an icon and label.
/// When the backend provides additional metadata (source, conflict info),
/// it is displayed here.
class SyncMetadataCard extends StatelessWidget {
  final SyncStatus syncStatus;

  const SyncMetadataCard({
    super.key,
    required this.syncStatus,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final (IconData icon, String label, Color color) = switch (syncStatus) {
      SyncStatus.syncing => (Icons.sync, 'Syncing...', c.textSecondary),
      SyncStatus.synced => (Icons.cloud_done, 'Synced', c.statusAlone),
      SyncStatus.error => (Icons.cloud_off, 'Sync Error', c.statusMissed),
      SyncStatus.idle => (Icons.cloud_queue, 'Not Synced', c.textSecondary),
    };

    return NeoCard(
      color: c.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (syncStatus == SyncStatus.syncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
