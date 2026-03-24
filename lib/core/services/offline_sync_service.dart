import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/prayer/domain/usecases/log_prayer_usecase.dart';

/// Manages offline synchronization of prayer logs using Hive for local storage
/// and connectivity_plus to detect when the network is restored.
class OfflineSyncService {
  static const String _boxName = 'offline_sync_queue';
  final LogPrayerUseCase _logPrayerUseCase;
  bool _isProcessing = false;

  OfflineSyncService(this._logPrayerUseCase);

  /// Initialize Hive and start listening to network changes.
  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<Map<dynamic, dynamic>>(_boxName);

    // Listen for network connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // If we are connected to mobile or wifi, try processing the queue
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        processQueue();
      }
    });
  }

  /// Adds a failed LogPrayer action to the offline queue.
  Future<void> enqueueAction({
    required String prayerName,
    required bool completed,
    required bool inJamaat,
    required String location,
  }) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    final action = {
      'prayerName': prayerName,
      'completed': completed,
      'inJamaat': inJamaat,
      'location': location,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.add(action);
  }

  /// Attempts to process all queued actions.
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
      if (box.isEmpty) return;

      // We process items one by one. If one fails, we stop processing (assume network is dead again).
      final keys = box.keys.toList();
      for (final key in keys) {
        final action = box.get(key);
        if (action == null) continue;

        try {
          await _logPrayerUseCase(
            prayerName: action['prayerName'] as String,
            completed: action['completed'] as bool,
            inJamaat: action['inJamaat'] as bool,
            location: action['location'] as String,
          );
          // If successful, remove from queue
          await box.delete(key);
        } catch (e) {
          // Sync failed (likely network error again), stop processing this batch
          break;
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
}
