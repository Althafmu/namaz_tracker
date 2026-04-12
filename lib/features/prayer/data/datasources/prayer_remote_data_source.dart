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
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (dateKey != null) 'date': dateKey,
    });
    return response.data as Map<String, dynamic>;
  }


  /// GET /api/streak/
  Future<Map<String, dynamic>> getStreak() async {
    final response = await dio.get('/api/streak/');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/prayers/history/?days=90
  Future<List<dynamic>> getWeeklyHistory({int days = 90}) async {
    final response = await dio.get('/api/prayers/history/', queryParameters: {
      'days': days,
    });
    return response.data as List<dynamic>;
  }

  /// GET /api/prayers/history/detailed/?year=2026&month=4
  /// Returns full DailyPrayerLog data for every day in the requested month.
  Future<List<dynamic>> getDetailedMonthHistory({
    required int year,
    required int month,
  }) async {
    final response = await dio.get('/api/prayers/history/detailed/', queryParameters: {
      'year': year,
      'month': month,
    });
    return response.data as List<dynamic>;
  }

  /// GET /api/prayers/reasons/
  /// Returns pre-aggregated reason counts: { "reasons": { "Work": 5, ... } }
  Future<Map<String, dynamic>> getReasonSummary() async {
    final response = await dio.get('/api/prayers/reasons/');
    return response.data as Map<String, dynamic>;
  }
}
