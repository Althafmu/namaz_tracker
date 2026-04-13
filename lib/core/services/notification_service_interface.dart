import 'package:adhan/adhan.dart';
import '../../features/prayer/domain/entities/prayer_notification_config.dart';

/// Interface for NotificationService allowing test mocking.
/// Implement this interface to create test doubles.
abstract class NotificationServiceInterface {
  bool get isInitialized;
  bool get permissionsGranted;
  bool get exactAlarmGranted;

  Future<void> initialize();
  Future<bool> checkPermissions();
  Future<Map<String, bool>> getPermissionDiagnostics();
  Future<bool> requestPermissions();
  Future<String> showTestNotification();
  Future<String> showTestAlarm({String alarmSound});
  Future<int> getPendingNotificationCount();
  Future<void> cancelAllNotifications();
  Future<int> schedulePrayerNotifications({
    required Coordinates coordinates,
    required String methodName,
    required bool useHanafi,
    required Map<String, PrayerNotificationConfig> prayerConfigs,
    String alarmSound,
    Map<String, int>? manualOffsets,
    int alarmDurationMinutes,
  });
}