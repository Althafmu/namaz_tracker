import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/features/prayer/data/models/streak_model.dart';

void main() {
  group('StreakModel', () {
    group('fromApiResponse', () {
      test('parses complete streak data', () {
        final response = {
          'current_streak': 7,
          'longest_streak': 14,
          'last_completed_date': '2026-04-14',
          'display_streak': 7,
        };

        final streak = StreakModel.fromApiResponse(response);

        expect(streak.currentStreak, 7);
        expect(streak.longestStreak, 14);
        expect(streak.lastCompletedDate, '2026-04-14');
        expect(streak.displayStreak, 7);
      });

      test('handles zero streak values', () {
        final response = {
          'current_streak': 0,
          'longest_streak': 0,
          'last_completed_date': null,
          'display_streak': 0,
        };

        final streak = StreakModel.fromApiResponse(response);

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.lastCompletedDate, null);
        expect(streak.displayStreak, 0);
      });

      test('handles empty response with defaults', () {
        final response = <String, dynamic>{};

        final streak = StreakModel.fromApiResponse(response);

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.lastCompletedDate, null);
        expect(streak.displayStreak, 0);
      });

      test('handles partial response', () {
        final response = {
          'current_streak': 5,
          'longest_streak': 10,
        };

        final streak = StreakModel.fromApiResponse(response);

        expect(streak.currentStreak, 5);
        expect(streak.longestStreak, 10);
        expect(streak.lastCompletedDate, null);
        expect(streak.displayStreak, 0);
      });
    });

    group('constructor', () {
      test('creates StreakModel with all fields', () {
        final streak = StreakModel(
          currentStreak: 7,
          longestStreak: 14,
          lastCompletedDate: '2026-04-14',
          displayStreak: 7,
        );

        expect(streak.currentStreak, 7);
        expect(streak.longestStreak, 14);
        expect(streak.lastCompletedDate, '2026-04-14');
        expect(streak.displayStreak, 7);
      });

      test('creates StreakModel with default values', () {
        final streak = StreakModel();

        expect(streak.currentStreak, 0);
        expect(streak.longestStreak, 0);
        expect(streak.lastCompletedDate, null);
        expect(streak.displayStreak, 0);
      });
    });
  });
}