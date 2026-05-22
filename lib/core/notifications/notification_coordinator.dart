import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/groups/services/group_activity_notification_service.dart';

class NotificationCoordinator {
  final GroupActivityNotificationService _activityService;
  Timer? _pollingTimer;
  String? _currentGroupId;
  String? _currentUsername;
  bool _pollingStarted = false;

  NotificationCoordinator({
    required GroupActivityNotificationService activityService,
  }) : _activityService = activityService;

  void startPolling({
    required String groupId,
    required String? currentUsername,
    Duration interval = const Duration(seconds: 30),
  }) {
    if (_pollingStarted) return;
    stopPolling();
    _pollingStarted = true;
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

    debugPrint('[NotificationCoordinator] Started polling every ${interval.inSeconds}s');

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

  void dispose() {
    stopPolling();
  }

  void updateUser(String? newUsername) {
    if (_currentUsername == newUsername) return;

    final groupId = _currentGroupId;
    final wasPolling = _pollingStarted;

    stopPolling();

    _currentUsername = newUsername;

    if (wasPolling && groupId != null) {
      startPolling(
        groupId: groupId,
        currentUsername: newUsername,
      );
    }
  }
}