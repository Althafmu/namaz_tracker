import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/sunnah_day_summary.dart';
import '../../domain/entities/sunnah_week_summary.dart';

/// Supabase implementation of Sunnah data source.
class SunnahRemoteDataSource {
  final SupabaseClient _client;

  SunnahRemoteDataSource({required SupabaseClient client}) : _client = client;

  static const String _tag = '[SunnahRemoteDataSource]';

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('No authenticated Supabase user');
    return id;
  }

  static SunnahDaySummary _emptyDay(String dateStr) {
    return SunnahDaySummary(
      date: dateStr,
      completedCount: 0,
      totalOpportunities: 0,
      completedPrayerTypes: const {},
    );
  }

  Future<SunnahDaySummary> getDailySummary({String? dateKey}) async {
    final date = dateKey ?? DateTime.now().toIso8601String().split('T')[0];
    final userId = _userId;

    final rows = await _client
        .from('sunnah_logs')
        .select()
        .eq('user_id', userId)
        .eq('date', date)
        .eq('completed', true);

    final completedTypes = <String>{};
    for (final row in rows) {
      completedTypes.add(row['prayer_type'] as String);
    }

    return SunnahDaySummary(
      date: date,
      completedCount: completedTypes.length,
      totalOpportunities: 4, // Assuming 4 rawatib sunnahs
      completedPrayerTypes: completedTypes,
    );
  }

  Future<SunnahDaySummary> logPrayer({
    required String prayerType,
    required bool completed,
    String? dateKey,
  }) async {
    final date = dateKey ?? DateTime.now().toIso8601String().split('T')[0];
    final userId = _userId;

    debugPrint('$_tag logPrayer($prayerType, $completed) on $date');

    if (completed) {
      await _client.from('sunnah_logs').upsert({
        'user_id': userId,
        'date': date,
        'prayer_type': prayerType,
        'completed': true,
      }, onConflict: 'user_id,date,prayer_type');
    } else {
      await _client
          .from('sunnah_logs')
          .delete()
          .eq('user_id', userId)
          .eq('date', date)
          .eq('prayer_type', prayerType);
    }

    return getDailySummary(dateKey: date);
  }

  Future<SunnahWeekSummary> getWeeklySummary({String? startDateKey}) async {
    // Basic implementation for weekly summary
    final date = startDateKey ?? DateTime.now().toIso8601String().split('T')[0];
    final endDate = DateTime.parse(date).add(const Duration(days: 6)).toIso8601String().split('T')[0];
    final userId = _userId;

    final rows = await _client
        .from('sunnah_logs')
        .select()
        .eq('user_id', userId)
        .gte('date', date)
        .lte('date', endDate)
        .eq('completed', true);

    int totalCompleted = 0;
    final Map<String, SunnahDaySummary> days = {};

    for (final row in rows) {
      final rowDate = row['date'] as String;
      final type = row['prayer_type'] as String;
      
      if (!days.containsKey(rowDate)) {
        days[rowDate] = _emptyDay(rowDate);
      }
      
      final day = days[rowDate]!;
      days[rowDate] = day.copyWith(
        completedCount: day.completedCount + 1,
        completedPrayerTypes: {...day.completedPrayerTypes, type},
      );
      totalCompleted++;
    }

    return SunnahWeekSummary(
      weekStart: date,
      weekEnd: endDate,
      totalCompleted: totalCompleted,
      totalOpportunities: 7 * 4,
      days: days.values.toList(),
    );
  }
}
