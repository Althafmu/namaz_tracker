import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/streak.dart';

void main() {
  group('Streak', () {
    group('constructor', () {
      test('creates streak with all fields', () {
        final streak = Streak(
          currentStreak: 5,
          longestStreak: 10,
          lastCompletedDate: '2026-04-14',
          displayStreak: 5,
        );

        expect(streak.currentStreak, 5);
        expect(streak.longestStreak, 10);
        expect(streak.lastCompletedDate, '2026-04-14');
        expect(streak.displayStreak, 5);
      });

      test('creates streak with default values', () {
        final streak = Streak();

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.lastCompletedDate, null);
        expect(streak.displayStreak, 0);
        expect(streak.protectorTokens, 3);
        expect(streak.maxProtectorTokens, 3);
      });
    });

    group('props', () {
      test('includes all fields for equality comparison', () {
        final streak = Streak(
          currentStreak: 5,
          longestStreak: 10,
          lastCompletedDate: '2026-04-14',
          displayStreak: 5,
        );

        expect(streak.props, containsAll([5, 10, '2026-04-14', 5]));
      });
    });

    group('equality', () {
      test('equal streaks have same hashCode', () {
        final streak1 = Streak(
          currentStreak: 5,
          longestStreak: 10,
          lastCompletedDate: '2026-04-14',
          displayStreak: 5,
        );
        final streak2 = Streak(
          currentStreak: 5,
          longestStreak: 10,
          lastCompletedDate: '2026-04-14',
          displayStreak: 5,
        );

        expect(streak1, equals(streak2));
        expect(streak1.hashCode, equals(streak2.hashCode));
      });

      test('different streaks are not equal', () {
        final streak1 = Streak(currentStreak: 5);
        final streak2 = Streak(currentStreak: 3);

        expect(streak1, isNot(equals(streak2)));
      });
    });
  });
}
