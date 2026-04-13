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
    final response = await dio.post('/api/prayers/log/', data: {
      'prayer': prayerName.toLowerCase(),
      'completed': completed,
      'in_jamaat': inJamaat,
      'location': location,
      'status': ?status,
      'reason': ?reason,
      'date': ?dateKey,
    });
    return response.data as Map<String, dynamic>;
  }


  /// GET /api/streak/
  Future<Map<String, dynamic>> getStreak() async {
    final response = await dio.get('/api/streak/');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/history/?days=90&page=1
  /// Returns paginated response: {results: [...], count, page, total_pages, page_size}
  Future<Map<String, dynamic>> getWeeklyHistory({int days = 90, int page = 1}) async {
    final response = await dio.get('/api/prayers/history/', queryParameters: {
      'days': days,
      'page': page,
    });
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/history/detailed/?year=2026&month=4&page=1
  /// Returns paginated response with full DailyPrayerLog data.
  Future<Map<String, dynamic>> getDetailedMonthHistory({
    required int year,
    required int month,
    int page = 1,
  }) async {
    final response = await dio.get('/api/prayers/history/detailed/', queryParameters: {
      'year': year,
      'month': month,
      'page': page,
    });
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/reasons/
  /// Returns pre-aggregated reason counts: { "reasons": { "Work": 5, ... } }
  Future<Map<String, dynamic>> getReasonSummary() async {
    final response = await dio.get('/api/prayers/reasons/');
    return response.data as Map<String, dynamic>;
  }
}
