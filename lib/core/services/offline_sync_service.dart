import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../features/prayer/data/repositories/offline_queue_repository.dart';
import '../../features/prayer/domain/usecases/log_prayer_usecase.dart';
import 'package:get_it/get_it.dart';
import '../../features/prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../features/prayer/presentation/bloc/settings/settings_event.dart';

/// Coordinates offline→online sync of queued prayer logs.
///
/// Listens for connectivity changes and drains the [OfflineQueueRepository]
/// when the network comes back. Does NOT own storage initialization.
class OfflineSyncService {
  final OfflineQueueRepository _queueRepository;
  final LogPrayerUseCase _logPrayerUseCase;
  bool _isProcessing = false;

  OfflineSyncService({
    required OfflineQueueRepository queueRepository,
    required LogPrayerUseCase logPrayerUseCase,
  })  : _queueRepository = queueRepository,
        _logPrayerUseCase = logPrayerUseCase;

  /// Start listening for connectivity changes.
  void startListening() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        processQueue();
      }
    });
  }

  /// Convenience: enqueue an action (delegates to repository).
  Future<void> enqueueAction({
    required String prayerName,
    required bool completed,
    required bool inJamaat,
    required String location,
    String? status,
    String? reason,
    String? dateKey,
  }) async {
    await _queueRepository.enqueueAction(
      prayerName: prayerName,
      completed: completed,
      inJamaat: inJamaat,
      location: location,
      status: status,
      reason: reason,
      dateKey: dateKey,
    );
  }

  /// Process all queued actions, retrying on network failure.
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      if (_queueRepository.isEmpty) return;

      final actions = _queueRepository.getAllActions();
      bool processedAny = false;
      for (final entry in actions) {
        final action = entry.value;
        try {
          await _logPrayerUseCase(
            prayerName: action['prayerName'] as String,
            completed: action['completed'] as bool,
            inJamaat: action['inJamaat'] as bool,
            location: action['location'] as String,
            status: action['status'] as String?,
            reason: action['reason'] as String?,
            dateKey: action['dateKey'] as String?,
          );
          await _queueRepository.dequeueAction(entry.key);
          processedAny = true;
        } catch (e) {
          debugPrint('[OfflineSync] Sync failed for queued action: $e');
          break; // Network still down — stop this batch
        }
      }
      
      if (processedAny) {
        try {
          GetIt.I<SettingsBloc>().add(const SyncSettingsToCloud());
        } catch (_) {}
      }
    } finally {
      _isProcessing = false;
    }
  }
}
