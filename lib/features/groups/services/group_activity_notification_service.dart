import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../core/services/notification_service_interface.dart';
import '../data/datasources/group_remote_datasource.dart';

class GroupActivityNotificationService {
  final GroupRemoteDataSource _dataSource;
  NotificationServiceInterface? _notificationService;
  
  DateTime? _lastCheckTime;
  DateTime? _lastNotificationTime;
  final Set<String> _seenActivityKeys = {};
  
  static const _notificationDebounceMinutes = 60;

  GroupActivityNotificationService({
    required GroupRemoteDataSource dataSource,
    NotificationServiceInterface? notificationService,
  }) : _dataSource = dataSource,
       _notificationService = notificationService;

  NotificationServiceInterface get _notifications {
    _notificationService ??= GetIt.instance<NotificationServiceInterface>();
    return _notificationService!;
  }

  String _generateActivityKey(Map<String, dynamic> activity) {
    final type = activity['type'] as String? ?? '';
    final username = activity['username'] as String? ?? '';
    final createdAt = activity['created_at'] as String? ?? '';
    return '${type}_${username}_$createdAt';
  }

  Future<void> checkNewActivity(int groupId, {bool silent = false, String? currentUsername}) async {
    try {
      final activities = await _dataSource.fetchGroupActivity(groupId);
      
      final newActivities = activities.where((activity) {
        final activityKey = _generateActivityKey(activity);
        
        if (_seenActivityKeys.contains(activityKey)) {
          return false;
        }
        
        final timestamp = DateTime.tryParse(activity['created_at'] as String? ?? '');
        if (timestamp == null || (_lastCheckTime != null && !timestamp.isAfter(_lastCheckTime!))) {
          return false;
        }
        
        final activityUsername = activity['username'] as String?;
        if (activityUsername != null && activityUsername == currentUsername) {
          return false;
        }
        
        _seenActivityKeys.add(activityKey);
        return true;
      }).toList();

      if (newActivities.isEmpty) {
        _lastCheckTime = DateTime.now();
        return;
      }

      for (final activity in newActivities) {
        if (!silent) {
          await _sendNotification(activity, groupId);
        }
      }
      
      _lastCheckTime = DateTime.now();
    } catch (e) {
      debugPrint('[GroupActivityNotification] Error checking activity: $e');
    }
  }

  Future<void> _sendNotification(Map<String, dynamic> activity, int groupId) async {
    final type = activity['type'] as String?;
    final message = activity['message'] as String?;

    if (type == null || message == null) return;

    if (type == 'join' || type == 'streak_milestone') {
      if (_shouldDebounce()) return;

      try {
        final title = type == 'join' ? 'New member joined' : 'Streak milestone!';
        final activityKey = _generateActivityKey(activity);
        await _notifications.showGroupActivityNotification(
          title: title,
          body: message,
          activityHashCode: activityKey.hashCode,
        );
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
  
  void clearSeenActivities() {
    _seenActivityKeys.clear();
  }
}