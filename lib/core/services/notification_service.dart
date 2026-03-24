import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_time_service.dart';

/// Handles scheduling and cancelling local OS notifications for Adhan and reminders.
///
/// Schedules 7 days ahead so alarms survive overnight and device restarts
/// (when paired with the BOOT_COMPLETED receiver in AndroidManifest.xml).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _permissionsGranted = false;

  bool get isInitialized => _isInitialized;
  bool get permissionsGranted => _permissionsGranted;

  /// Initialize the notification plugin and timezones.
  /// Safe to call at startup — does NOT request permissions.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone setup — no flutter_timezone dependency needed
    try {
      tz.initializeTimeZones();
      final localName = DateTime.now().timeZoneName;
      try {
        tz.setLocalLocation(tz.getLocation(localName));
      } catch (_) {
        // timeZoneName may return abbreviation on some devices — fall back to UTC
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      debugPrint('[Notification] Timezone init failed: $e');
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    // Plugin setup
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );
    } catch (e) {
      debugPrint('[Notification] Plugin init failed: $e');
      _isInitialized = true;
      return;
    }

    _isInitialized = true;
  }

  /// Request notification and exact alarm permissions.
  /// Call from the UI layer when the user explicitly enables alerts.
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    try {
      final androidImpl = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        final notifGranted =
            await androidImpl.requestNotificationsPermission();
        final alarmGranted =
            await androidImpl.requestExactAlarmsPermission();
        _permissionsGranted =
            (notifGranted ?? false) && (alarmGranted ?? false);
      } else {
        final iosImpl = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImpl != null) {
          _permissionsGranted = await iosImpl.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
              false;
        } else {
          _permissionsGranted = true;
        }
      }
    } catch (e) {
      debugPrint('[Notification] Permission request failed: $e');
      _permissionsGranted = false;
    }

    return _permissionsGranted;
  }

  /// Cancels all previously scheduled prayer notifications.
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('[Notification] Cancel all failed: $e');
    }
  }

  /// Schedule prayer notifications for the next 7 days.
  ///
  /// ID scheme: (dayOffset * 100) + (prayerIndex * 10) + alertType
  ///   alertType: 1 = adhan, 2 = reminder
  Future<int> schedulePrayerNotifications({
    required Coordinates coordinates,
    required String methodName,
    required bool useHanafi,
    required bool adhanAlerts,
    required bool reminderAlerts,
    required int reminderMinutes,
    required bool reminderIsBefore,
  }) async {
    await cancelAllNotifications();

    if (!adhanAlerts && !reminderAlerts) return 0;
    if (!_isInitialized) await initialize();

    int scheduledCount = 0;
    final now = DateTime.now();

    final method = PrayerTimeService.calculationMethods[methodName] ??
        CalculationMethod.north_america;
    final params = method.getParameters();
    params.madhab = useHanafi ? Madhab.hanafi : Madhab.shafi;

    // Schedule for 7 days ahead
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final dateComponents = DateComponents(date.year, date.month, date.day);
      final times = PrayerTimes(coordinates, dateComponents, params);

      final prayerTimesMap = {
        'Fajr': times.fajr,
        'Dhuhr': times.dhuhr,
        'Asr': times.asr,
        'Maghrib': times.maghrib,
        'Isha': times.isha,
      };

      int prayerIndex = 1;
      for (final entry in prayerTimesMap.entries) {
        final prayerName = entry.key;
        final prayerTime = entry.value;

        // Only schedule if the time is in the future
        if (prayerTime.isAfter(now)) {
          // 1. Schedule Adhan Alert
          if (adhanAlerts) {
            final adhanId = (dayOffset * 100) + (prayerIndex * 10) + 1;
            final success = await _scheduleAlarm(
              id: adhanId,
              title: "Time for $prayerName",
              body: "It's time to pray $prayerName.",
              scheduledTime: prayerTime,
            );
            if (success) scheduledCount++;
          }

          // 2. Schedule Reminder Alert
          if (reminderAlerts) {
            final reminderTime = reminderIsBefore
                ? prayerTime.subtract(Duration(minutes: reminderMinutes))
                : prayerTime.add(Duration(minutes: reminderMinutes));

            if (reminderTime.isAfter(now)) {
              final reminderId = (dayOffset * 100) + (prayerIndex * 10) + 2;
              final whenText = reminderIsBefore
                  ? "$reminderMinutes mins before $prayerName"
                  : "$reminderMinutes mins after $prayerName";

              final success = await _scheduleAlarm(
                id: reminderId,
                title: "Prayer Reminder",
                body: whenText,
                scheduledTime: reminderTime,
              );
              if (success) scheduledCount++;
            }
          }
        }
        prayerIndex++;
      }
    }

    debugPrint('[Notification] Scheduled $scheduledCount notifications for 7 days');
    return scheduledCount;
  }

  /// Schedule a single alarm. Returns true on success.
  Future<bool> _scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'prayer_alerts',
        'Prayer Alerts',
        channelDescription: 'Notifications for Adhan and reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails darwinPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledTime,
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (e) {
      debugPrint('[Notification] Failed to schedule alarm $id: $e');
      return false;
    }
  }
}
