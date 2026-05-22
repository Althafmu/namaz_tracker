import 'package:flutter/foundation.dart';

import '../../features/prayer/data/repositories/offline_queue_repository.dart';
import '../../features/prayer/domain/usecases/log_prayer_usecase.dart';

/// Offline sync service.
///
/// DISABLED during Supabase migration — no queued actions will be replayed
/// against the old Django backend. Queue will be cleared when Supabase
/// prayer logging is implemented.
class OfflineSyncService {
  final OfflineQueueRepository _queueRepository;
  final LogPrayerUseCase _logPrayerUseCase; // kept for DI compatibility

  OfflineSyncService({
    required OfflineQueueRepository queueRepository,
    required LogPrayerUseCase logPrayerUseCase,
  })  : _queueRepository = queueRepository,
        _logPrayerUseCase = logPrayerUseCase;

  /// No-op during migration — avoids retry storms to localhost.
  void startListening() {
    debugPrint('[OfflineSyncService] startListening() — disabled (Django disabled)');
  }

  /// No-op during migration.
  Future<void> enqueueAction({
    required String prayerName,
    required bool completed,
    required bool inJamaat,
    required String location,
    String? status,
    String? reason,
    String? dateKey,
  }) async {
    debugPrint('[OfflineSyncService] enqueueAction() — disabled (Django disabled)');
  }

  /// No-op during migration — does NOT drain queue to localhost.
  Future<void> processQueue() async {
    debugPrint('[OfflineSyncService] processQueue() — disabled (Django disabled)');
  }
}
