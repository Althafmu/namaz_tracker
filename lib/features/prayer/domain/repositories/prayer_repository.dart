import '../entities/prayer.dart';
import '../entities/streak.dart';

/// Abstract repository contract — domain layer does not know about data sources.
abstract class PrayerRepository {
  /// Get today's list of prayers with their completion status.
  Future<List<Prayer>> getDailyStatus();

  /// Log a single prayer as completed.
  Future<List<Prayer>> logPrayer({
    required String prayerName,
    required bool completed,
    bool inJamaat = false,
    String location = 'home',
  });

  /// Get the user's current streak info.
  Future<Streak> getStreak();

  /// Get weekly prayer history (list of daily prayer lists).
  Future<List<List<Prayer>>> getWeeklyHistory();
}
