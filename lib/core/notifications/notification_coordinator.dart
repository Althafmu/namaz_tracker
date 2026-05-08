import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/groups/services/group_activity_notification_service.dart';

class NotificationCoordinator {
  final GroupActivityNotificationService _activityService;
  Timer? _pollingTimer;
  int? _currentGroupId;
  String? _currentUsername;
  bool _pollingStarted = false;

  NotificationCoordinator({
    required GroupActivityNotificationService activityService,
  }) : _activityService = activityService;

  void startPolling({
    required int groupId,
    required String? currentUsername,
    Duration interval = const Duration(minutes: 5),
  }) {
    stopPolling();
    _currentGroupId = groupId;
    _currentUsername = currentUsername;
    
    _pollingTimer = Timer.periodic(interval, (_) async {
      if (_currentGroupId != null) {
        await _activityService.checkNewActivity(
          _currentGroupId!,
          currentUsername: _currentUsername,
        );
      }
    });
    
    debugPrint('[NotificationCoordinator] Started polling every ${interval.inMinutes} min');
    
    _activityService.checkNewActivity(
      groupId,
      currentUsername: currentUsername,
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentGroupId = null;
    _currentUsername = null;
    _pollingStarted = false;
    debugPrint('[NotificationCoordinator] Stopped polling');
  }
}