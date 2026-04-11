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
  }) async {
    final response = await dio.post('/api/prayers/log/', data: {
      'prayer': prayerName.toLowerCase(),
      'completed': completed,
      'in_jamaat': inJamaat,
      'location': location,
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
}
