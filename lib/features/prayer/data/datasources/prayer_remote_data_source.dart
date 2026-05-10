import 'package:dio/dio.dart';

/// Remote data source using Dio to communicate with the Django backend.
class PrayerRemoteDataSource {
  final Dio dio;

  PrayerRemoteDataSource({required this.dio});

  /// GET /api/prayers/today/
  Future<Map<String, dynamic>> getTodayLog() async {
    final response = await dio.get('/api/v1/prayers/today/');
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/prayers/log/ — Log a single prayer
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
    final Map<String, dynamic> data = {
      'prayer_name': prayerName.toLowerCase(),
      'completed': completed,
      'in_jamaat': inJamaat,
      'location': location,
      'prayed_jumah': prayedJumah,
    };
    if (status != null) data['status'] = status;
    if (reason != null) data['reason'] = reason;
    if (dateKey != null) data['date'] = dateKey;
    final response = await dio.post('/api/v1/prayers/log/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/streak/
  Future<Map<String, dynamic>> getStreak() async {
    final response = await dio.get('/api/v1/streak/');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/history/?days=90&page=1
  /// Returns paginated response: {results: [...], count, page, total_pages, page_size}
  Future<Map<String, dynamic>> getWeeklyHistory({
    int days = 90,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/api/v1/prayers/history/',
      queryParameters: {'days': days, 'page': page},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/history/detailed/?year=2026&month=4&page=1
  /// Returns paginated response with full DailyPrayerLog data.
  Future<Map<String, dynamic>> getDetailedMonthHistory({
    required int year,
    required int month,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/api/v1/prayers/history/detailed/',
      queryParameters: {'year': year, 'month': month, 'page': page},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/reasons/
  /// Returns pre-aggregated reason counts: { "reasons": { "Work": 5, ... } }
  Future<Map<String, dynamic>> getReasonSummary() async {
    final response = await dio.get('/api/v1/prayers/reasons/');
    return response.data as Map<String, dynamic>;
  }

  // ── Phase 2: Streak Freeze System ──

  /// POST /api/streak/consume-token/
  /// Consume a protector token to save streak after Qada prayer.
  /// Body: { "date": "2026-04-15" } (optional, defaults to yesterday)
  Future<Map<String, dynamic>> consumeProtectorToken({String? date}) async {
    final Map<String, dynamic> data = {};
    if (date != null) data['date'] = date;
    final response = await dio.post('/api/v1/streak/consume-token/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/prayers/excused/
  /// Mark a day as excused (travel, sickness, women's period).
  /// Body: { "date": "2026-04-15", "reason": "travel", "prayer_names": ["dhuhr", "asr", "maghrib", "isha"] }
  Future<Map<String, dynamic>> setExcusedDay({
    required String date,
    String? reason,
    Set<String>? prayerNames,
  }) async {
    final Map<String, dynamic> data = {'date': date};
    if (reason != null) data['reason'] = reason;
    if (prayerNames != null && prayerNames.isNotEmpty) {
      data['prayer_names'] = prayerNames.toList();
    }
    final response = await dio.post('/api/v1/prayers/excused/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/prayers/excused/clear/
  /// Clear a day's excused state and restore remaining prayers to pending.
  Future<Map<String, dynamic>> clearExcusedDay({required String date}) async {
    final response = await dio.post(
      '/api/v1/prayers/excused/clear/',
      data: {'date': date},
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Phase 3: New Backend Features ──

  /// GET /api/v1/prayers/undo/ — undo last prayer log
  Future<Map<String, dynamic>> undoLastPrayerLog({
    String? prayerName,
    String? dateKey,
  }) async {
    final queryParams = <String, dynamic>{};
    if (prayerName != null) {
      queryParams['prayer'] = prayerName.toLowerCase();
    }
    if (dateKey != null) {
      queryParams['date'] = dateKey;
    }
    final response = await dio.get('/api/v1/prayers/undo/', queryParameters: queryParams);
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/sync/metadata/
  /// Retrieve sync metadata (last sync time, source, conflict info).
  Future<Map<String, dynamic>> getSyncMetadata() async {
    final response = await dio.get('/api/v1/sync/metadata/');
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/notifications/pause-today/
  /// Pause all notifications for the remainder of today.
  Future<Map<String, dynamic>> pauseNotificationsForToday() async {
    final response = await dio.post('/api/v1/notifications/pause-today/');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/notifications/pause-today/
  /// Check if notifications are paused for today.
  Future<Map<String, dynamic>> getNotificationsPauseStatus() async {
    final response = await dio.get('/api/v1/notifications/pause-today/');
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /api/notifications/pause-today/
  /// Resume (unpause) notifications for today.
  Future<Map<String, dynamic>> resumeNotificationsForToday() async {
    final response = await dio.delete('/api/v1/notifications/pause-today/');
    return response.data as Map<String, dynamic>;
  }
}
