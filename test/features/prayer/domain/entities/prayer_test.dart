import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/prayer.dart';

void main() {
  group('Prayer', () {
    group('defaultPrayers', () {
      test('returns list of 5 prayers with correct names', () {
        final prayers = Prayer.defaultPrayers();

        expect(prayers.length, 5);
        expect(prayers[0].name, 'Fajr');
        expect(prayers[1].name, 'Dhuhr');
        expect(prayers[2].name, 'Asr');
        expect(prayers[3].name, 'Maghrib');
        expect(prayers[4].name, 'Isha');
      });

      test('all default prayers are not completed', () {
        final prayers = Prayer.defaultPrayers();

        for (final prayer in prayers) {
          expect(prayer.isCompleted, false);
        }
      });
    });

    group('copyWith', () {
      test('copies with updated isCompleted', () {
        final original = Prayer.defaultPrayers().first;
        final updated = original.copyWith(isCompleted: true);

        expect(updated.isCompleted, true);
        expect(updated.name, original.name);
        expect(updated.timeRange, original.timeRange);
      });

      test('copies with inJamaat', () {
        final original = Prayer.defaultPrayers().first;
        final updated = original.copyWith(inJamaat: true);

        expect(updated.inJamaat, true);
      });

      test('copies with location', () {
        final original = Prayer.defaultPrayers().first;
        final updated = original.copyWith(location: 'mosque');

        expect(updated.location, 'mosque');
      });

      test('copies with status', () {
        final original = Prayer.defaultPrayers().first;
        final updated = original.copyWith(status: 'late');

        expect(updated.status, 'late');
      });

      test('copies with reason', () {
        final original = Prayer.defaultPrayers().first;
        final updated = original.copyWith(reason: 'Work');

        expect(updated.reason, 'Work');
      });
    });

    group('props', () {
      test('includes all fields for equality comparison', () {
        final prayer = Prayer(
          name: 'Fajr',
          timeRange: '05:00 - 06:00',
          isCompleted: true,
          inJamaat: true,
          location: 'mosque',
          status: 'on_time',
          reason: 'test',
        );

        expect(
          prayer.props,
          containsAll(['Fajr', '05:00 - 06:00', true, true, 'mosque', 'on_time', 'test']),
        );
      });
    });
  });
}