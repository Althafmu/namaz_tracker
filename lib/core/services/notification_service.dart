import 'dart:typed_data';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'prayer_time_service.dart';
import '../../features/prayer/domain/entities/prayer_notification_config.dart';
import 'notification_service_interface.dart';

/// Handles scheduling and cancelling local OS notifications for Adhan and reminders.
///
/// Schedules 3 days ahead so alarms survive overnight and device restarts
/// (when paired with the BOOT_COMPLETED receiver in AndroidManifest.xml).
///
/// This class is NOT a singleton - it should be injected via DI (GetIt)
/// and can be mocked for testing by implementing [NotificationServiceInterface].
class NotificationService implements NotificationServiceInterface {
  final FlutterLocalNotificationsPlugin _plugin;

  bool _isInitialized = false;
  bool _permissionsGranted = false;
  bool _exactAlarmGranted = false;

  bool get isInitialized => _isInitialized;
  bool get permissionsGranted => _permissionsGranted;
  bool get exactAlarmGranted => _exactAlarmGranted;

  /// Creates a NotificationService instance.
  /// For production use, inject via GetIt in injection_container.dart.
  /// For testing, inject a mock implementing [NotificationServiceInterface].
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Resets internal state. Call this in tests to ensure clean state.
  @visibleForTesting
  void resetState() {
    _isInitialized = false;
    _permissionsGranted = false;
    _exactAlarmGranted = false;
  }

  /// Initialize the notification plugin and timezones.
  /// Safe to call at startup — does NOT request permissions.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Timezone setup — uses flutter_timezone for proper IANA name
    try {
      tz.initializeTimeZones();
      String timeZoneName;
      try {
        timeZoneName = await FlutterTimezone.getLocalTimezone()
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('[Notification] FlutterTimezone timed out or failed: $e');
        // Fallback: try to guess from offset
        final offset = DateTime.now().timeZoneOffset;
        timeZoneName = _tzNameFromOffset(offset);
      }
      debugPrint('[Notification] Detected timezone: $timeZoneName');
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        // If the IANA name still fails, fall back to UTC as last resort
        debugPrint('[Notification] Failed to set timezone "$timeZoneName", falling back to UTC');
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
          AndroidInitializationSettings('mipmap/launcher_icon');

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

      await _plugin.initialize(
        settings: initializationSettings,
      );
    } catch (e) {
      debugPrint('[Notification] Plugin init failed: $e');
      _isInitialized = true;
      return;
    }

    _isInitialized = true;
  }

  /// Check current permission status without prompting the user.
  /// Checks both notification permission AND exact alarm permission.
  Future<bool> checkPermissions() async {
    if (!_isInitialized) await initialize();

    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        final notifGranted =
            await androidImpl.areNotificationsEnabled() ?? false;
        final exactAlarmGranted =
            await androidImpl.canScheduleExactNotifications() ?? false;
        _permissionsGranted = notifGranted;
        _exactAlarmGranted = exactAlarmGranted;
        debugPrint(
            '[Notification] Permissions check: notif=$notifGranted, exactAlarm=$exactAlarmGranted');
      } else {
        // iOS / other — assume granted if plugin initialized
        _permissionsGranted = true;
        _exactAlarmGranted = true;
      }
    } catch (e) {
      debugPrint('[Notification] Permission check failed: $e');
      _permissionsGranted = false;
      _exactAlarmGranted = false;
    }

    return _permissionsGranted;
  }

  /// Returns a human-readable diagnostic of all permission states.
  Future<Map<String, bool>> getPermissionDiagnostics() async {
    if (!_isInitialized) await initialize();

    bool notifGranted = false;
    bool exactAlarmGranted = false;

    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        notifGranted =
            await androidImpl.areNotificationsEnabled() ?? false;
        exactAlarmGranted =
            await androidImpl.canScheduleExactNotifications() ?? false;
      }
    } catch (e) {
      debugPrint('[Notification] Diagnostics failed: $e');
    }

    return {
      'notifications': notifGranted,
      'exactAlarms': exactAlarmGranted,
      'initialized': _isInitialized,
    };
  }

  /// Request notification and exact alarm permissions.
  /// Call from the UI layer when the user explicitly enables alerts.
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        final notifGranted =
            await androidImpl.requestNotificationsPermission();
        
        // Only request exact alarms if not already granted. Trying to request it
        // when USE_EXACT_ALARM is present might cause issues on some devices.
        bool exactGranted = await androidImpl.canScheduleExactNotifications() ?? false;
        if (!exactGranted) {
          try {
            exactGranted = await androidImpl.requestExactAlarmsPermission() ?? false;
          } catch (e) {
            debugPrint('[Notification] requestExactAlarmsPermission failed: $e');
            exactGranted = false;
          }
        }
        
        _permissionsGranted =
            (notifGranted ?? false) && exactGranted;
      } else {
        final iosImpl = _plugin
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

  /// ─── DIAGNOSTIC: Fire a notification right now to verify the pipeline ───
  /// Returns 'OK' on success or 'ERR: ...' with actual error on failure.
  Future<String> showTestNotification() async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        return 'ERR: initialize() failed: $e';
      }
    }
    if (!_isInitialized) return 'ERR: Plugin never initialized';

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'prayer_alerts',
        'Prayer Alerts',
        channelDescription: 'Notifications for Adhan times',
        icon: 'mipmap/launcher_icon',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.show(
        id: 99999,
        title: '✅ Notifications Working!',
        body: 'If you see this, prayer alerts will work correctly.',
        notificationDetails: details,
      );
      debugPrint('[Notification] Test notification fired successfully');
      return 'OK';
    } catch (e, st) {
      debugPrint('[Notification] Test notification FAILED: $e\n$st');
      return 'ERR: $e';
    }
  }

  /// ─── DIAGNOSTIC: Fire a FULL ALARM in 5 seconds to verify exact alarms ───
  Future<String> showTestAlarm({String alarmSound = 'system'}) async {
    if (!_isInitialized) {
      try {
        await initialize();
      } catch (e) {
        return 'ERR: initialize() failed: $e';
      }
    }
    if (!_isInitialized) return 'ERR: Plugin never initialized';

    try {
      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
      final result = await _scheduleAlarm(
        id: 99998,
        title: "⏰ Alarm Test",
        body: "If you see this and hear the alarm, your Prayer Reminders are working perfectly!",
        scheduledTime: scheduledTime,
        isAlarmStyle: true,
        alarmSound: alarmSound,
      );
      if (result == null) {
        debugPrint('[Notification] Test alarm scheduled for 5 seconds from now');
        return 'OK';
      } else {
        return 'ERR: $result';
      }
    } catch (e, st) {
      debugPrint('[Notification] Test alarm FAILED: $e\n$st');
      return 'ERR: $e';
    }
  }

  /// Returns the count of currently pending (scheduled) notifications.
  Future<int> getPendingNotificationCount() async {
    try {
      final pending =
          await _plugin.pendingNotificationRequests();
      debugPrint('[Notification] Pending notifications: ${pending.length}');
      for (final n in pending) {
        debugPrint('  → id=${n.id} title="${n.title}"');
      }
      return pending.length;
    } catch (e) {
      debugPrint('[Notification] Failed to get pending: $e');
      return -1;
    }
  }

  /// Cancels all previously scheduled prayer notifications.
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[Notification] Cancel all failed: $e');
    }
  }

  /// Schedule prayer notifications for the next 7 days.
  ///
  /// ID scheme: (dayOffset * 100) + (prayerIndex * 10) + alertType
  Future<int> schedulePrayerNotifications({
    required Coordinates coordinates,
    required String methodName,
    required bool useHanafi,
    required Map<String, PrayerNotificationConfig> prayerConfigs,
    String alarmSound = 'system',
    Map<String, int>? manualOffsets,
    int alarmDurationMinutes = 1,
  }) async {
    await cancelAllNotifications();

    if (!_isInitialized) await initialize();

    int scheduledCount = 0;
    final now = DateTime.now();

    // Schedule for 3 days ahead to prevent hitting Android exact alarm limits (50 alarms)
    for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final times = PrayerTimeService.calculateTimesForDate(
        coordinates: coordinates,
        date: date,
        methodName: methodName,
        useHanafi: useHanafi,
        manualOffsets: manualOffsets,
      );

      final prayerTimesMap = {
        'Fajr': times.fajr,
        'Dhuhr': times.dhuhr,
        'Asr': times.asr,
        'Maghrib': times.maghrib,
        'Isha': times.isha,
      };

      // End-of-window times for streak protection:
      //   Fajr   → sunrise
      //   Dhuhr  → Asr start
      //   Asr    → Maghrib start
      //   Maghrib→ Isha - 30 mins (earliest prayer preferred)
      //   Isha   → 10:00 PM (end of active day for streak protection)
      final ishaEnd = DateTime(date.year, date.month, date.day, 22, 00);
      final prayerEndTimes = {
        'Fajr': times.sunrise,
        'Dhuhr': times.asr,
        'Asr': times.maghrib,
        'Maghrib': times.isha.subtract(const Duration(minutes: 30)),
        'Isha': ishaEnd,
      };

      int prayerIndex = 1;
      for (final entry in prayerTimesMap.entries) {
        final prayerName = entry.key;
        final prayerTime = entry.value;
        final config = prayerConfigs[prayerName] ?? const PrayerNotificationConfig();

        // Only schedule if the time is in the future
        if (prayerTime.isAfter(now)) {
          // 1. Schedule Adhan Alert (standard notification)
          if (config.adhanAlerts) {
            final adhanId = (dayOffset * 100) + (prayerIndex * 10) + 1;
            final result = await _scheduleAlarm(
              id: adhanId,
              title: "Time for $prayerName",
              body: "It's time to pray $prayerName.",
              scheduledTime: prayerTime,
            );
            if (result == null) scheduledCount++;
          }

          // 2. Schedule Reminder Alert (alarm-style with sound)
          if (config.reminderAlerts) {
            final reminderTime = config.reminderIsBefore
                ? prayerTime.subtract(Duration(minutes: config.reminderMinutes))
                : prayerTime.add(Duration(minutes: config.reminderMinutes));

            if (reminderTime.isAfter(now)) {
              final reminderId = (dayOffset * 100) + (prayerIndex * 10) + 2;
              final whenText = config.reminderIsBefore
                  ? "${config.reminderMinutes} mins before $prayerName"
                  : "${config.reminderMinutes} mins after $prayerName";

              final result = await _scheduleAlarm(
                id: reminderId,
                title: "🔔 Prayer Reminder",
                body: whenText,
                scheduledTime: reminderTime,
                isAlarmStyle: true,
                alarmSound: alarmSound,
                alarmDurationMinutes: alarmDurationMinutes,
              );
              if (result == null) scheduledCount++;
            }
          }
        }

        // 3. Schedule Streak Protection (15 mins before window ends)
        if (config.streakProtection) {
          final endTime = prayerEndTimes[prayerName];
          if (endTime != null) {
            final streakAlertTime =
                endTime.subtract(const Duration(minutes: 15));
            if (streakAlertTime.isAfter(now) &&
                streakAlertTime.isAfter(prayerTime)) {
              final streakId = (dayOffset * 100) + (prayerIndex * 10) + 3;
              final result = await _scheduleAlarm(
                id: streakId,
                title: "⏰ $prayerName time ending soon!",
                body:
                    "Only 15 mins left — don't miss $prayerName and keep your streak!",
                scheduledTime: streakAlertTime,
                isAlarmStyle: true,
                alarmSound: alarmSound,
                alarmDurationMinutes: alarmDurationMinutes,
              );
              if (result == null) scheduledCount++;
            }
          }
        }
        prayerIndex++;
      }
    }

    debugPrint('[Notification] Scheduled $scheduledCount notifications for 3 days');

    // Schedule daily 10 PM reminder
    final reminderCount = await _scheduleDailyReminders(now: now);
    scheduledCount += reminderCount;

    return scheduledCount;
  }

  /// Schedule daily reminder notifications at 10 PM for the next 3 days.
  /// ID scheme: 9000 + dayOffset
  Future<int> _scheduleDailyReminders({required DateTime now}) async {
    int count = 0;

    for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final reminderTime = DateTime(date.year, date.month, date.day, 22, 0); // 10 PM

      if (reminderTime.isAfter(now)) {
        final reminderId = 9000 + dayOffset;
        final result = await _scheduleAlarm(
          id: reminderId,
          title: "🌙 Daily Prayer Reminder",
          body: "Have you completed all your prayers today? Don't break your streak!",
          scheduledTime: reminderTime,
          isAlarmStyle: true,
          alarmDurationMinutes: 1,
        );
        if (result == null) count++;
      }
    }

    debugPrint('[Notification] Scheduled $count daily reminders at 10 PM');
    return count;
  }

  /// Schedule a single alarm. Returns null on success, or error string on failure.
  ///
  /// [isAlarmStyle] – when true, uses a high-priority alarm channel with
  /// sound, vibration, and full-screen intent (like a phone alarm).
  Future<String?> _scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool isAlarmStyle = false,
    String alarmSound = 'system',
    int alarmDurationMinutes = 1,
  }) async {
    try {
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      // Standard notification channel (Adhan alerts)
      const standardChannel = AndroidNotificationDetails(
        'prayer_alerts',
        'Prayer Alerts',
        channelDescription: 'Notifications for Adhan times',
        icon: 'mipmap/launcher_icon',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      // Resolve sound object based on selected sound option
      AndroidNotificationSound? androidSound;
      if (alarmSound == 'system') {
        androidSound = const UriAndroidNotificationSound('content://settings/system/alarm_alert');
      } else if (alarmSound.startsWith('/')) {
        androidSound = UriAndroidNotificationSound('file://$alarmSound');
      } else {
        final String resourceName = alarmSound.split('.').first;
        androidSound = RawResourceAndroidNotificationSound(resourceName);
      }

      final safeSoundId = alarmSound.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

      // Alarm-style channel (Reminders & Streak Protection)
      final alarmChannel = AndroidNotificationDetails(
        'prayer_alarms_$safeSoundId', // changed to include sound id to force channel update
        'Prayer Alarms',
        channelDescription: 'Alarm-style alerts for prayer reminders',
        icon: 'mipmap/launcher_icon',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: androidSound,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        timeoutAfter: alarmDurationMinutes * 60000, // Stop ringing after dynamic duration
        additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT (loops sound until dismissed)
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'stop_id_1',
            'Stop Alarm 🛑',
            cancelNotification: true,
            showsUserInterface: false, // Prevents forcefully opening the app, just stops the alarm
          ),
        ],
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformChannelSpecifics = NotificationDetails(
        android: isAlarmStyle ? alarmChannel : standardChannel,
        iOS: darwinDetails,
      );

      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tzScheduledTime,
          notificationDetails: platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        if (e.toString().contains('exact_alarms_not_permitted')) {
          debugPrint('[Notification] Exact alarms not permitted, falling back to inexact for $id');
          await _plugin.zonedSchedule(
            id: id,
            title: title,
            body: body,
            scheduledDate: tzScheduledTime,
            notificationDetails: platformChannelSpecifics,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } else {
          rethrow;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[Notification] Failed to schedule alarm $id: $e');
      return e.toString();
    }
  }

  /// Best-effort offset → IANA timezone mapping for when FlutterTimezone
  /// is unavailable (e.g. emulator, timeout).
  static String _tzNameFromOffset(Duration offset) {
    final minutes = offset.inMinutes;
    const offsetMap = <int, String>{
      -720: 'Etc/GMT+12',
      -660: 'Pacific/Pago_Pago',
      -600: 'Pacific/Honolulu',
      -540: 'America/Anchorage',
      -480: 'America/Los_Angeles',
      -420: 'America/Denver',
      -360: 'America/Chicago',
      -300: 'America/New_York',
      -240: 'America/Halifax',
      -210: 'America/St_Johns',
      -180: 'America/Sao_Paulo',
      -60: 'Atlantic/Azores',
      0: 'Europe/London',
      60: 'Europe/Paris',
      120: 'Europe/Helsinki',
      180: 'Europe/Moscow',
      210: 'Asia/Tehran',
      240: 'Asia/Dubai',
      270: 'Asia/Kabul',
      300: 'Asia/Karachi',
      330: 'Asia/Kolkata',
      345: 'Asia/Kathmandu',
      360: 'Asia/Dhaka',
      390: 'Asia/Yangon',
      420: 'Asia/Bangkok',
      480: 'Asia/Shanghai',
      540: 'Asia/Tokyo',
      570: 'Australia/Darwin',
      600: 'Australia/Sydney',
      660: 'Pacific/Noumea',
      720: 'Pacific/Auckland',
      780: 'Pacific/Apia',
    };
    return offsetMap[minutes] ?? 'UTC';
  }
}
