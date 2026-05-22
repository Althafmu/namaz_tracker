import 'package:namaz_tracker/features/prayer/domain/entities/prayer.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/streak.dart';

/// Abstract interface for prayer_logs persistence.
/// Implemented by SupabasePrayerService (production) and FakePrayerService (tests).
abstract class PrayerService {
  Future<void> upsertLog({
    required String prayerName,
    required String status,
    bool inJamaat = false,
    String? reason,
    String? dateKey,
  });

  Future<List<Prayer>> fetchDayLogs({
    String? dateKey,
    required List<Prayer> basePrayers,
  });

  Future<Map<String, List<Prayer>>> fetchMonthLogs({
    required int year,
    required int month,
  });

  Future<Map<String, int>> getWeeklyHistory({int days = 90});
  
  Future<Map<String, int>> getReasonSummary();

  Future<Streak> getStreak();

  Future<Streak> consumeProtectorToken({String? date});

  Future<List<Prayer>> setExcusedDay({
    required String date,
    String? reason,
    Set<String>? prayerNames,
  });

  Future<List<Prayer>> clearExcusedDay({required String date});

  Future<void> undoLastPrayerLog({
    required String prayerName,
    String? dateKey,
  });
}
