import 'package:flutter/foundation.dart';

/// MIGRATION STUB — All Django endpoints disabled.
/// Will be replaced with Supabase implementations in the next phase.
class PrayerRemoteDataSource {
  PrayerRemoteDataSource({required dynamic dio}); // dio kept for DI compatibility

  static const String _tag = '[PrayerRemoteDataSource]';

  Future<Map<String, dynamic>> getTodayLog() async {
    debugPrint('$_tag getTodayLog() — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> logPrayer({
    required String prayerName,
    required bool completed,
    bool inJamaat = false,
    String location = 'home',
    String? status,
    String? reason,
    String? dateKey,
    bool prayedJumah = false,
  }) async {
    debugPrint('$_tag logPrayer($prayerName) — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> getStreak() async {
    debugPrint('$_tag getStreak() — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> getWeeklyHistory({int days = 90, int page = 1}) async {
    debugPrint('$_tag getWeeklyHistory() — stubbed (Django disabled)');
    return {'results': [], 'count': 0, 'page': 1, 'total_pages': 1, 'page_size': 90};
  }

  Future<Map<String, dynamic>> getDetailedMonthHistory({
    required int year,
    required int month,
    int page = 1,
  }) async {
    debugPrint('$_tag getDetailedMonthHistory($year-$month) — stubbed (Django disabled)');
    return {'results': [], 'count': 0, 'page': 1, 'total_pages': 1};
  }

  Future<Map<String, dynamic>> getReasonSummary() async {
    debugPrint('$_tag getReasonSummary() — stubbed (Django disabled)');
    return {'reasons': {}};
  }

  Future<Map<String, dynamic>> consumeProtectorToken({String? date}) async {
    debugPrint('$_tag consumeProtectorToken() — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> setExcusedDay({
    required String date,
    String? reason,
    Set<String>? prayerNames,
  }) async {
    debugPrint('$_tag setExcusedDay($date) — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> clearExcusedDay({required String date}) async {
    debugPrint('$_tag clearExcusedDay($date) — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> undoLastPrayerLog({
    String? prayerName,
    String? dateKey,
  }) async {
    debugPrint('$_tag undoLastPrayerLog() — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> getSyncMetadata() async {
    debugPrint('$_tag getSyncMetadata() — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> pauseNotificationsForToday() async {
    debugPrint('$_tag pauseNotificationsForToday() — stubbed (Django disabled)');
    return {};
  }

  Future<Map<String, dynamic>> getNotificationsPauseStatus() async {
    debugPrint('$_tag getNotificationsPauseStatus() — stubbed (Django disabled)');
    return {'paused': false};
  }

  Future<Map<String, dynamic>> resumeNotificationsForToday() async {
    debugPrint('$_tag resumeNotificationsForToday() — stubbed (Django disabled)');
    return {};
  }
}
