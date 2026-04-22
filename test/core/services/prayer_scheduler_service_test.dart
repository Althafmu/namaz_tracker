import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/core/services/notification_service.dart';
import 'package:namaz_tracker/core/services/prayer_scheduler_service.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/prayer_notification_config.dart';
import 'package:namaz_tracker/features/prayer/presentation/bloc/settings/settings_state.dart';

class _RecordingNotificationService extends NotificationService {
  _RecordingNotificationService({this.permissionState = false})
    : super(plugin: FlutterLocalNotificationsPlugin());

  final bool permissionState;
  int scheduleCallCount = 0;

  @override
  bool get permissionsGranted => permissionState;

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<int> schedulePrayerNotifications({
    required Coordinates coordinates,
    required String methodName,
    required bool useHanafi,
    required Map<String, PrayerNotificationConfig> prayerConfigs,
    String alarmSound = 'system',
    Map<String, int>? manualOffsets,
    int alarmDurationMinutes = 1,
    Set<String>? excusedDays,
    String? intentLevel,
  }) async {
    scheduleCallCount += 1;
    return 7;
  }
}

void main() {
  group('PrayerSchedulerService consent gate', () {
    test(
      'does not schedule when notifications are not permitted in settings',
      () async {
        final notificationService = _RecordingNotificationService(
          permissionState: true,
        );
        final scheduler = PrayerSchedulerService(
          notificationService: notificationService,
        );

        scheduler.seedCachedCoordinates(24.8607, 67.0011);

        final result = await scheduler.scheduleNotifications(
          const SettingsState(notificationsPermitted: false),
        );

        expect(result, 0);
        expect(notificationService.scheduleCallCount, 0);
      },
    );

    test('schedules when notifications are permitted in settings', () async {
      final notificationService = _RecordingNotificationService();
      final scheduler = PrayerSchedulerService(
        notificationService: notificationService,
      );

      scheduler.seedCachedCoordinates(24.8607, 67.0011);

      final result = await scheduler.scheduleNotifications(
        const SettingsState(notificationsPermitted: true),
      );

      expect(result, 7);
      expect(notificationService.scheduleCallCount, 1);
    });
  });
}
