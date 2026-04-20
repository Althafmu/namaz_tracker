import 'package:dio/dio.dart';

import '../../domain/entities/sunnah_day_summary.dart';
import '../../domain/entities/sunnah_week_summary.dart';

class SunnahRemoteDataSource {
  final Dio dio;

  SunnahRemoteDataSource({required this.dio});

  Future<SunnahDaySummary> getDailySummary({String? dateKey}) async {
    final response = await dio.get(
      '/api/v2/sunnah/daily/',
      queryParameters: {
        ...?dateKey == null ? null : {'date': dateKey},
      },
    );
    return SunnahDaySummary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SunnahDaySummary> logPrayer({
    required String prayerType,
    required bool completed,
    String? dateKey,
  }) async {
    await dio.post(
      '/api/v2/sunnah/log/',
      data: {
        'prayer_type': prayerType,
        'completed': completed,
        ...?dateKey == null ? null : {'date': dateKey},
      },
    );
    return getDailySummary(dateKey: dateKey);
  }

  Future<SunnahWeekSummary> getWeeklySummary({String? startDateKey}) async {
    final response = await dio.get(
      '/api/v2/sunnah/weekly/',
      queryParameters: {
        ...?startDateKey == null ? null : {'start_date': startDateKey},
      },
    );
    return SunnahWeekSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
