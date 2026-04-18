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

  // ── Phase 2: Streak Freeze System ──

  /// Consume a protector token to save streak after Qada prayer.
  /// Returns updated streak info with tokens_remaining.
  Future<Streak> consumeProtectorToken({String? date});

  /// Mark a day as excused (travel, sickness, women's period).
  /// Returns the updated prayer log.
  Future<List<Prayer>> setExcusedDay({
    required String date,
    String? reason,
  });

  // ── Phase 3: New Backend Features ──

  /// Undo the last prayer log. Returns the updated prayer list.
  Future<List<Prayer>> undoLastPrayerLog();

  /// Get sync metadata (last sync, source, conflict info).
  Future<Map<String, dynamic>> getSyncMetadata();

  /// Pause notifications for today. Returns backend confirmation.
  Future<Map<String, dynamic>> pauseNotificationsForToday();

  /// Check if notifications are paused for today.
  Future<Map<String, dynamic>> getNotificationsPauseStatus();
}
