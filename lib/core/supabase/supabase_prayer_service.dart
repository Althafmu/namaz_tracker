import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/prayer/domain/entities/prayer.dart';
import '../../features/prayer/domain/entities/streak.dart';
import 'prayer_service.dart';

/// Production implementation of [PrayerService] backed by Supabase.
class SupabasePrayerService implements PrayerService {
  final SupabaseClient _client;

  SupabasePrayerService(this._client);

  static const _tag = '[SupabasePrayerService]';

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('No authenticated Supabase user');
    return id;
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> upsertLog({
    required String prayerName,
    required String status,
    bool inJamaat = false,
    String? reason,
    String? dateKey,
  }) async {
    final date = dateKey ?? _todayKey();
    final userId = _userId;
    debugPrint('$_tag upsertLog $prayerName/$status on $date');

    await _client.from('prayer_logs').upsert(
      {
        'user_id': userId,
        'date': date,
        'prayer_name': prayerName.toLowerCase(),
        'status': status,
        'in_jamaat': inJamaat,
        'reason': reason,
      },
      onConflict: 'user_id,date,prayer_name',
    );
  }

  @override
  Future<List<Prayer>> fetchDayLogs({
    String? dateKey,
    required List<Prayer> basePrayers,
  }) async {
    final date = dateKey ?? _todayKey();
    final userId = _userId;
    debugPrint('$_tag fetchDayLogs for $date');

    final rows = await _client
        .from('prayer_logs')
        .select()
        .eq('user_id', userId)
        .eq('date', date);

    final logMap = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      logMap[(row['prayer_name'] as String).toLowerCase()] =
          row as Map<String, dynamic>;
    }

    return basePrayers.map((prayer) {
      final row = logMap[prayer.name.toLowerCase()];
      if (row == null) return prayer;
      final status = row['status'] as String? ?? 'pending';
      return prayer.copyWith(
        isCompleted: status != 'pending' && status != 'missed',
        inJamaat: row['in_jamaat'] as bool? ?? false,
        status: status,
        reason: row['reason'] as String?,
      );
    }).toList();
  }

  @override
  Future<Map<String, List<Prayer>>> fetchMonthLogs({
    required int year,
    required int month,
  }) async {
    final userId = _userId;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = month < 12
        ? '$year-${(month + 1).toString().padLeft(2, '0')}-01'
        : '${year + 1}-01-01';

    debugPrint('$_tag fetchMonthLogs $year-$month');

    final rows = await _client
        .from('prayer_logs')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate)
        .lt('date', endDate);

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final date = row['date'] as String;
      grouped.putIfAbsent(date, () => []).add(row as Map<String, dynamic>);
    }

    final result = <String, List<Prayer>>{};
    for (final entry in grouped.entries) {
      final basePrayers = Prayer.defaultPrayers();
      final logMap = <String, Map<String, dynamic>>{};
      for (final row in entry.value) {
        logMap[(row['prayer_name'] as String).toLowerCase()] = row;
      }
      result[entry.key] = basePrayers.map((prayer) {
        final row = logMap[prayer.name.toLowerCase()];
        if (row == null) return prayer;
        final status = row['status'] as String? ?? 'pending';
        return prayer.copyWith(
          isCompleted: status != 'pending' && status != 'missed',
          inJamaat: row['in_jamaat'] as bool? ?? false,
          status: status,
          reason: row['reason'] as String?,
        );
      }).toList();
    }
    return result;
  }

  @override
  Future<Map<String, int>> getWeeklyHistory({int days = 90}) async {
    final userId = _userId;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffString = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';

    final rows = await _client
        .from('prayer_logs')
        .select('date')
        .eq('user_id', userId)
        .gte('date', cutoffString)
        .neq('status', 'pending')
        .neq('status', 'missed')
        .neq('status', 'excused'); // Excused doesn't count as 'completed' usually, but depends on logic.

    final result = <String, int>{};
    for (final row in rows) {
      final date = row['date'] as String;
      result[date] = (result[date] ?? 0) + 1;
    }
    return result;
  }

  @override
  Future<Map<String, int>> getReasonSummary() async {
    final userId = _userId;
    final rows = await _client
        .from('prayer_logs')
        .select('reason')
        .eq('user_id', userId)
        .eq('status', 'missed')
        .not('reason', 'is', null);

    final result = <String, int>{};
    for (final row in rows) {
      final reason = row['reason'] as String?;
      if (reason != null && reason.isNotEmpty) {
        result[reason] = (result[reason] ?? 0) + 1;
      }
    }
    return result;
  }

  @override
  Future<Streak> getStreak() async {
    final userId = _userId;
    
    // 1. Force a recalculation to ensure the streak is completely up to date
    //    (Handles cases where days passed without the user opening the app)
    try {
      await _client.rpc('recalculate_user_streak', params: {'target_user_id': userId});
    } catch (e) {
      debugPrint('$_tag rpc recalculate_user_streak failed: $e');
    }

    // 2. Fetch the newly recalculated streak
    final row = await _client
        .from('streaks')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) {
      return const Streak();
    }

    return Streak(
      currentStreak: row['current_streak'] as int? ?? 0,
      longestStreak: row['longest_streak'] as int? ?? 0,
      lastCompletedDate: row['last_completed_date'] as String?,
      protectorTokens: row['protector_tokens'] as int? ?? 3,
    );
  }

  @override
  Future<Streak> consumeProtectorToken({String? date}) async {
    final userId = _userId;
    
    // Read current tokens
    final row = await _client
        .from('streaks')
        .select('protector_tokens, current_streak, longest_streak, last_completed_date')
        .eq('user_id', userId)
        .maybeSingle();
        
    int tokens = row?['protector_tokens'] as int? ?? 3;
    if (tokens > 0) {
      tokens -= 1;
      await _client.from('streaks').upsert({
        'user_id': userId,
        'protector_tokens': tokens,
        'current_streak': row?['current_streak'] as int? ?? 0,
        'longest_streak': row?['longest_streak'] as int? ?? 0,
        'last_completed_date': row?['last_completed_date'],
      });
    }

    return getStreak();
  }

  @override
  Future<List<Prayer>> setExcusedDay({
    required String date,
    String? reason,
    Set<String>? prayerNames,
  }) async {
    final userId = _userId;
    final targetPrayers = prayerNames?.isNotEmpty == true
        ? prayerNames!.toList()
        : ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    final List<Map<String, dynamic>> upserts = [];
    for (final prayerName in targetPrayers) {
      upserts.add({
        'user_id': userId,
        'date': date,
        'prayer_name': prayerName.toLowerCase(),
        'status': 'excused',
        'reason': reason ?? 'excused',
        'in_jamaat': false,
      });
    }

    await _client.from('prayer_logs').upsert(
      upserts,
      onConflict: 'user_id,date,prayer_name',
    );

    return fetchDayLogs(dateKey: date, basePrayers: Prayer.defaultPrayers());
  }

  @override
  Future<List<Prayer>> clearExcusedDay({required String date}) async {
    final userId = _userId;

    // Delete rows where status = 'excused' for this date
    await _client
        .from('prayer_logs')
        .delete()
        .eq('user_id', userId)
        .eq('date', date)
        .eq('status', 'excused');

    return fetchDayLogs(dateKey: date, basePrayers: Prayer.defaultPrayers());
  }

  @override
  Future<void> undoLastPrayerLog({
    required String prayerName,
    String? dateKey,
  }) async {
    final date = dateKey ?? _todayKey();
    final userId = _userId;
    debugPrint('$_tag undoLastPrayerLog $prayerName on $date');

    await _client
        .from('prayer_logs')
        .delete()
        .eq('user_id', userId)
        .eq('date', date)
        .eq('prayer_name', prayerName.toLowerCase());
  }
}
