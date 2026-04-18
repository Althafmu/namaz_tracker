import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/core/services/status_helper.dart';

void main() {
  group('StatusHelper', () {
    group('label', () {
      test('returns correct label for all known statuses', () {
        expect(StatusHelper.label('on_time'), 'On Time');
        expect(StatusHelper.label('late'), 'Late');
        expect(StatusHelper.label('qada'), 'Qada');
        expect(StatusHelper.label('missed'), 'Missed');
        expect(StatusHelper.label('excused'), 'Excused');
        expect(StatusHelper.label('pending'), 'Pending');
      });

      test('returns Pending for unknown status', () {
        expect(StatusHelper.label('unknown_status'), 'Pending');
        expect(StatusHelper.label(''), 'Pending');
        expect(StatusHelper.label('ONTIME'), 'Pending');
      });
    });

    group('tooltip', () {
      test('returns tooltip for all known statuses', () {
        expect(StatusHelper.tooltip('on_time'), contains('within'));
        expect(StatusHelper.tooltip('late'), contains('after'));
        expect(StatusHelper.tooltip('qada'), contains('Make-up'));
        expect(StatusHelper.tooltip('missed'), contains('passed'));
        expect(StatusHelper.tooltip('excused'), contains('preserved'));
        expect(StatusHelper.tooltip('pending'), contains('not yet'));
      });

      test('returns fallback tooltip for unknown status', () {
        expect(StatusHelper.tooltip('unknown'), contains('could not'));
      });
    });

    group('description', () {
      test('returns description for late with boundary explanation', () {
        final desc = StatusHelper.description('late');
        expect(desc, contains('after the ideal window'));
        expect(desc, contains('server determines'));
      });

      test('returns description for qada with boundary explanation', () {
        final desc = StatusHelper.description('qada');
        expect(desc, contains('make-up'));
        expect(desc, contains('next prayer'));
      });

      test('returns description for missed with recovery info', () {
        final desc = StatusHelper.description('missed');
        expect(desc, contains('protector'));
      });

      test('returns fallback description for unknown status', () {
        final desc = StatusHelper.description('xyz');
        expect(desc, contains('could not be determined'));
      });
    });

    group('countsForStreak', () {
      test('on_time counts for streak', () {
        expect(StatusHelper.countsForStreak('on_time'), true);
      });

      test('late counts for streak', () {
        expect(StatusHelper.countsForStreak('late'), true);
      });

      test('qada counts for streak', () {
        expect(StatusHelper.countsForStreak('qada'), true);
      });

      test('missed does not count for streak', () {
        expect(StatusHelper.countsForStreak('missed'), false);
      });

      test('excused does not count (freezes) for streak', () {
        expect(StatusHelper.countsForStreak('excused'), false);
      });

      test('pending does not count for streak', () {
        expect(StatusHelper.countsForStreak('pending'), false);
      });

      test('unknown does not count for streak', () {
        expect(StatusHelper.countsForStreak('unknown'), false);
      });
    });

    group('freezesStreak', () {
      test('excused freezes streak', () {
        expect(StatusHelper.freezesStreak('excused'), true);
      });

      test('other statuses do not freeze streak', () {
        expect(StatusHelper.freezesStreak('on_time'), false);
        expect(StatusHelper.freezesStreak('missed'), false);
        expect(StatusHelper.freezesStreak('pending'), false);
      });
    });

    group('isKnown', () {
      test('returns true for all known statuses', () {
        expect(StatusHelper.isKnown('on_time'), true);
        expect(StatusHelper.isKnown('late'), true);
        expect(StatusHelper.isKnown('qada'), true);
        expect(StatusHelper.isKnown('missed'), true);
        expect(StatusHelper.isKnown('excused'), true);
        expect(StatusHelper.isKnown('pending'), true);
      });

      test('returns false for unknown statuses', () {
        expect(StatusHelper.isKnown('unknown'), false);
        expect(StatusHelper.isKnown(''), false);
        expect(StatusHelper.isKnown('LATE'), false);
      });
    });

    group('emoji', () {
      test('returns emoji for all known statuses', () {
        expect(StatusHelper.emoji('on_time'), '✅');
        expect(StatusHelper.emoji('late'), '⏰');
        expect(StatusHelper.emoji('qada'), '🔄');
        expect(StatusHelper.emoji('missed'), '❌');
        expect(StatusHelper.emoji('excused'), '🛡️');
        expect(StatusHelper.emoji('pending'), '⏳');
      });

      test('returns question mark for unknown status', () {
        expect(StatusHelper.emoji('unknown'), '❓');
      });
    });
  });
}
