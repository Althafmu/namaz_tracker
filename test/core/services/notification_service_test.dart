import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:namaz_tracker/core/services/notification_service.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/prayer_notification_config.dart';
import 'package:timezone/timezone.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class FakeTZDateTime extends Fake implements TZDateTime {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

Map<String, PrayerNotificationConfig> _allPrayerConfigs(
  PrayerNotificationConfig config,
) {
  return {
    'Fajr': config,
    'Dhuhr': config,
    'Asr': config,
    'Maghrib': config,
    'Isha': config,
  };
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeTZDateTime());
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exact);
    registerFallbackValue(DateTimeComponents.time);
  });

  group('NotificationService scheduling safety', () {
    test(
      'schedules the nightly reminder on the standard notification channel',
      () async {
        final plugin = MockFlutterLocalNotificationsPlugin();
        final scheduledCalls = <Map<String, dynamic>>[];

        when(
          () => plugin.initialize(
            settings: any(named: 'settings'),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
            onDidReceiveBackgroundNotificationResponse: any(
              named: 'onDidReceiveBackgroundNotificationResponse',
            ),
          ),
        ).thenAnswer((_) async => true);

        when(() => plugin.cancelAll()).thenAnswer((_) async {});

        when(
          () => plugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenAnswer((invocation) async {
          scheduledCalls.add({
            'id': invocation.namedArguments[#id],
            'title': invocation.namedArguments[#title],
            'body': invocation.namedArguments[#body],
            'notificationDetails':
                invocation.namedArguments[#notificationDetails],
          });
        });

        final service = NotificationService(plugin: plugin);

        final count = await service.schedulePrayerNotifications(
          coordinates: Coordinates(24.8607, 67.0011),
          methodName: 'MWL',
          useHanafi: false,
          prayerConfigs: _allPrayerConfigs(const PrayerNotificationConfig()),
          intentLevel: 'foundation',
        );

        expect(count, greaterThan(0));
        final nightlyReminders = scheduledCalls
            .where((call) => call['title'] == '🌙 Daily Prayer Reminder')
            .toList();
        expect(nightlyReminders, isNotEmpty);
        expect(
          nightlyReminders.every(
            (call) => call['id'] >= 9000 && call['id'] <= 9002,
          ),
          isTrue,
        );
        expect(
          nightlyReminders.every(
            (call) =>
                (call['notificationDetails'] as NotificationDetails)
                    .android
                    ?.channelId ==
                'prayer_alerts',
          ),
          isTrue,
        );
      },
    );

    test(
      'schedules nightly reminders even when prayer reminders are off',
      () async {
        final plugin = MockFlutterLocalNotificationsPlugin();
        final scheduledCalls = <Map<String, dynamic>>[];

        when(
          () => plugin.initialize(
            settings: any(named: 'settings'),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
            onDidReceiveBackgroundNotificationResponse: any(
              named: 'onDidReceiveBackgroundNotificationResponse',
            ),
          ),
        ).thenAnswer((_) async => true);

        when(() => plugin.cancelAll()).thenAnswer((_) async {});

        when(
          () => plugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).thenAnswer((invocation) async {
          scheduledCalls.add({
            'id': invocation.namedArguments[#id],
            'title': invocation.namedArguments[#title],
            'body': invocation.namedArguments[#body],
            'notificationDetails':
                invocation.namedArguments[#notificationDetails],
          });
        });

        final service = NotificationService(plugin: plugin);

        final count = await service.schedulePrayerNotifications(
          coordinates: Coordinates(24.8607, 67.0011),
          methodName: 'MWL',
          useHanafi: false,
          prayerConfigs: {
            'Fajr': const PrayerNotificationConfig(
              adhanAlerts: false,
              reminderAlerts: false,
              reminderIsBefore: true,
              streakProtection: false,
            ),
            'Dhuhr': const PrayerNotificationConfig(adhanAlerts: false),
            'Asr': const PrayerNotificationConfig(adhanAlerts: false),
            'Maghrib': const PrayerNotificationConfig(adhanAlerts: false),
            'Isha': const PrayerNotificationConfig(adhanAlerts: false),
          },
          intentLevel: 'foundation',
        );

        expect(count, 3); // nightly reminders
        final nightlyReminders = scheduledCalls
            .where((call) => call['title'] == '🌙 Daily Prayer Reminder')
            .toList();
        expect(nightlyReminders.length, 3);
        expect(scheduledCalls.length, 3); // only nightly
      },
    );
  });
}
