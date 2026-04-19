import 'package:dio/dio.dart';

/// Remote data source using Dio to communicate with the Django backend.
class PrayerRemoteDataSource {
  final Dio dio;

  PrayerRemoteDataSource({required this.dio});

  /// GET /api/prayers/today/
  Future<Map<String, dynamic>> getTodayLog() async {
    final response = await dio.get('/api/prayers/today/');
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
  }) async {
    final Map<String, dynamic> data = {
      'prayer': prayerName.toLowerCase(),
      'completed': completed,
      'in_jamaat': inJamaat,
      'location': location,
    };
    if (status != null) data['status'] = status;
    if (reason != null) data['reason'] = reason;
    if (dateKey != null) data['date'] = dateKey;
    final response = await dio.post('/api/prayers/log/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/streak/
  Future<Map<String, dynamic>> getStreak() async {
    final response = await dio.get('/api/streak/');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/history/?days=90&page=1
  /// Returns paginated response: {results: [...], count, page, total_pages, page_size}
  Future<Map<String, dynamic>> getWeeklyHistory({
    int days = 90,
    int page = 1,
  }) async {
    final response = await dio.get(
      '/api/prayers/history/',
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
      '/api/prayers/history/detailed/',
      queryParameters: {'year': year, 'month': month, 'page': page},
    );
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/reasons/
  /// Returns pre-aggregated reason counts: { "reasons": { "Work": 5, ... } }
  Future<Map<String, dynamic>> getReasonSummary() async {
    final response = await dio.get('/api/prayers/reasons/');
    return response.data as Map<String, dynamic>;
  }

  // ── Phase 2: Streak Freeze System ──

  /// POST /api/streak/consume-token/
  /// Consume a protector token to save streak after Qada prayer.
  /// Body: { "date": "2026-04-15" } (optional, defaults to yesterday)
  Future<Map<String, dynamic>> consumeProtectorToken({String? date}) async {
    final Map<String, dynamic> data = {};
    if (date != null) data['date'] = date;
    final response = await dio.post('/api/streak/consume-token/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/prayers/excused/
  /// Mark a day as excused (travel, sickness, women's period).
  /// Body: { "date": "2026-04-15", "reason": "travel" }
  Future<Map<String, dynamic>> setExcusedDay({
    required String date,
    String? reason,
  }) async {
    final Map<String, dynamic> data = {'date': date};
    if (reason != null) data['reason'] = reason;
    final response = await dio.post('/api/prayers/excused/', data: data);
    return response.data as Map<String, dynamic>;
  }

  // ── Phase 3: New Backend Features ──

  /// POST /api/prayers/undo/
  /// Undo the last prayer log. Returns the updated daily prayer log.
  Future<Map<String, dynamic>> undoLastPrayerLog({
    String? prayerName,
    String? dateKey,
  }) async {
    final data = <String, dynamic>{};
    if (prayerName != null) {
      data['prayer'] = prayerName.toLowerCase();
    }
    if (dateKey != null) {
      data['date'] = dateKey;
    }
    final response = await dio.post('/api/prayers/undo/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/sync/metadata/
  /// Retrieve sync metadata (last sync time, source, conflict info).
  Future<Map<String, dynamic>> getSyncMetadata() async {
    final response = await dio.get('/api/sync/metadata/');
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/notifications/pause-today/
  /// Pause all notifications for the remainder of today.
  Future<Map<String, dynamic>> pauseNotificationsForToday() async {
    final response = await dio.post('/api/notifications/pause-today/');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/notifications/pause-today/
  /// Check if notifications are paused for today.
  Future<Map<String, dynamic>> getNotificationsPauseStatus() async {
    final response = await dio.get('/api/notifications/pause-today/');
    return response.data as Map<String, dynamic>;
  }
}
