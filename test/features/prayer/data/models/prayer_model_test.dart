import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/features/prayer/data/models/prayer_model.dart';

void main() {
  group('PrayerModel', () {
    group('fromApiResponse', () {
      test('parses basic prayer completion status', () {
        final response = {
          'fajr': true,
          'dhuhr': false,
          'asr': true,
          'maghrib': false,
          'isha': true,
        };

        final prayers = PrayerModel.fromApiResponse(response);

        expect(prayers.length, 5);
        expect(prayers[0].name, 'Fajr');
        expect(prayers[0].isCompleted, true);
        expect(prayers[1].name, 'Dhuhr');
        expect(prayers[1].isCompleted, false);
        expect(prayers[2].name, 'Asr');
        expect(prayers[2].isCompleted, true);
        expect(prayers[3].name, 'Maghrib');
        expect(prayers[3].isCompleted, false);
        expect(prayers[4].name, 'Isha');
        expect(prayers[4].isCompleted, true);
      });

      test('parses inJamaat status', () {
        final response = {
          'fajr': true,
          'fajr_in_jamaat': true,
          'dhuhr': true,
          'dhuhr_in_jamaat': false,
        };

        final prayers = PrayerModel.fromApiResponse(response);

        expect(prayers[0].inJamaat, true);
        expect(prayers[1].inJamaat, false);
      });

      test('parses location', () {
        final response = {
          'location': 'mosque',
        };

        final prayers = PrayerModel.fromApiResponse(response);

        for (final prayer in prayers) {
          expect(prayer.location, 'mosque');
        }
      });

      test('parses status for each prayer', () {
        final response = {
          'fajr_status': 'on_time',
          'dhuhr_status': 'late',
          'asr_status': 'missed',
        };

        final prayers = PrayerModel.fromApiResponse(response);

        expect(prayers[0].status, 'on_time');
        expect(prayers[1].status, 'late');
        expect(prayers[2].status, 'missed');
        expect(prayers[3].status, 'pending'); // default
        expect(prayers[4].status, 'pending'); // default
      });

      test('parses reason for each prayer', () {
        final response = {
          'fajr_reason': 'Slept in',
          'dhuhr_reason': 'Work',
          'asr_reason': null,
        };

        final prayers = PrayerModel.fromApiResponse(response);

        expect(prayers[0].reason, 'Slept in');
        expect(prayers[1].reason, 'Work');
        expect(prayers[2].reason, null);
      });

      test('handles empty response with defaults', () {
        final response = <String, dynamic>{};

        final prayers = PrayerModel.fromApiResponse(response);

        expect(prayers.length, 5);
        for (final prayer in prayers) {
          expect(prayer.isCompleted, false);
          expect(prayer.inJamaat, false);
          expect(prayer.location, 'home');
          expect(prayer.status, 'pending');
          expect(prayer.reason, null);
        }
      });

      test('handles partial response', () {
        final response = {
          'fajr': true,
          'isha': true,
        };

        final prayers = PrayerModel.fromApiResponse(response);

        expect(prayers[0].isCompleted, true);
        expect(prayers[1].isCompleted, false); // default
        expect(prayers[2].isCompleted, false); // default
        expect(prayers[3].isCompleted, false); // default
        expect(prayers[4].isCompleted, true);
      });
    });

    group('constructor', () {
      test('creates PrayerModel with all fields', () {
        final prayer = PrayerModel(
          name: 'Fajr',
          timeRange: '05:00 - 06:00',
          isCompleted: true,
          inJamaat: true,
          location: 'mosque',
          status: 'on_time',
          reason: 'test',
        );

        expect(prayer.name, 'Fajr');
        expect(prayer.timeRange, '05:00 - 06:00');
        expect(prayer.isCompleted, true);
        expect(prayer.inJamaat, true);
        expect(prayer.location, 'mosque');
        expect(prayer.status, 'on_time');
        expect(prayer.reason, 'test');
      });
    });
  });
}