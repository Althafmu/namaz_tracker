import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_time_service.dart';

/// Handles scheduling and cancelling local OS notifications for Adhan and reminders.
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

    // Timezone setup — wrapped to prevent crashes
    try {
      tz.initializeTimeZones();
      String timeZoneName;
      try {
        final timeZoneData = await FlutterTimezone.getLocalTimezone()
            .timeout(const Duration(seconds: 5));
        timeZoneName = timeZoneData.toString();
        if (timeZoneName.startsWith("TimezoneInfo(")) {
          final regex = RegExp(r'TimezoneInfo\(([^,]+),');
          final match = regex.firstMatch(timeZoneName);
          if (match != null) {
            timeZoneName = match.group(1) ?? 'UTC';
          }
        }
      } catch (_) {
        timeZoneName = 'UTC';
      }
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    // Plugin setup — wrapped to prevent crashes
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: false, // Don't request at init
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
      debugPrint('Notification plugin init failed: $e');
      _isInitialized = true;
      return;
    }

    _isInitialized = true;
  }

  /// Request notification and exact alarm permissions.
  /// Call this when the user explicitly enables alerts.
  /// Returns true if permissions were granted.
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    try {
      // Android 13+ notification permission
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
        // iOS — request via DarwinNotificationDetails
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
          _permissionsGranted = true; // Unknown platform, assume granted
        }
      }
    } catch (e) {
      debugPrint('Permission request failed: $e');
      _permissionsGranted = false;
    }

    return _permissionsGranted;
  }

  /// Cancels all previously scheduled prayer notifications.
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Cancel notifications failed: $e');
    }
  }

  /// Calculates prayer times for TODAY and schedules notifications.
  /// Only schedules for the current day — re-run daily on app launch.
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
    final dateComponents = DateComponents(now.year, now.month, now.day);

    final method = PrayerTimeService.calculationMethods[methodName] ??
        CalculationMethod.north_america;
    final params = method.getParameters();
    params.madhab = useHanafi ? Madhab.hanafi : Madhab.shafi;

    final times = PrayerTimes(coordinates, dateComponents, params);

    // Schedule for all 5 prayers
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
          final adhanId = prayerIndex * 10 + 1;
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
            final reminderId = prayerIndex * 10 + 2;
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

    debugPrint('Scheduled $scheduledCount notifications for today');
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
      debugPrint('Failed to schedule alarm $id: $e');
      return false;
    }
  }
}
