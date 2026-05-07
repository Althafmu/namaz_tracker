import 'package:flutter/foundation.dart';
import '../data/datasources/group_remote_datasource.dart';

class GroupActivityNotificationService {
  final GroupRemoteDataSource _dataSource;
  
  DateTime? _lastCheckTime;
  DateTime? _lastNotificationTime;
  
  static const _notificationDebounceMinutes = 60;

  GroupActivityNotificationService({
    required GroupRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  Future<void> checkNewActivity(int groupId, {bool silent = false}) async {
    try {
      final activities = await _dataSource.fetchGroupActivity(groupId);
      
      final newActivities = activities.where((activity) {
        final timestamp = DateTime.tryParse(activity['created_at'] as String? ?? '');
        return timestamp != null && 
            (_lastCheckTime == null || timestamp.isAfter(_lastCheckTime!));
      }).toList();

      if (newActivities.isEmpty) {
        _lastCheckTime = DateTime.now();
        return;
      }

      for (final activity in newActivities) {
        if (!silent) {
          await _sendNotification(activity);
        }
      }
      
      _lastCheckTime = DateTime.now();
    } catch (e) {
      debugPrint('[GroupActivityNotification] Error checking activity: $e');
    }
  }

  Future<void> _sendNotification(Map<String, dynamic> activity) async {
    final type = activity['type'] as String?;
    final message = activity['message'] as String?;

    if (type == null || message == null) return;

    if (type == 'join' || type == 'streak_milestone') {
      if (_shouldDebounce()) return;

      try {
        debugPrint('[GroupActivityNotification] Would show: $message');
        _lastNotificationTime = DateTime.now();
      } catch (e) {
        debugPrint('[GroupActivityNotification] Error: $e');
      }
    }
  }

  bool _shouldDebounce() {
    if (_lastNotificationTime == null) return false;
    
    final minutesSinceLastNotification = DateTime.now().difference(_lastNotificationTime!).inMinutes;
    return minutesSinceLastNotification < _notificationDebounceMinutes;
  }

  void resetCheckTime() {
    _lastCheckTime = DateTime.now();
  }
}