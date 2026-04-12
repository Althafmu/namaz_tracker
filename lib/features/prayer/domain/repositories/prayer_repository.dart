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
    String? status,
    String? reason,
    String? dateKey,
  });

  /// Get the user's current streak info.
  Future<Streak> getStreak();

  /// Get prayer history map (date string -> completed count).
  Future<Map<String, int>> getWeeklyHistory({int days = 90});

  /// Get full detailed prayer history for a specific month.
  /// Returns date string -> list of Prayer with full status/reason/inJamaat.
  Future<Map<String, List<Prayer>>> getDetailedMonthHistory({
    required int year,
    required int month,
  });

  /// Get pre-aggregated reason counts (all-time).
  /// Returns reason string -> count.
  Future<Map<String, int>> getReasonSummary();
}
