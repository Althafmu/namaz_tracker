import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/time_service.dart';
import '../../../../core/supabase/prayer_service.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/prayer_repository.dart';

/// Prayer repository — Supabase implementation.
///
/// logPrayer and getDailyStatus are LIVE via Supabase.
/// All other methods are stubbed pending next migration phase.
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerService prayerService;

  PrayerRepositoryImpl({required this.prayerService});

  static const _tag = '[PrayerRepositoryImpl]';

  // ── LIVE: Supabase prayer_logs ────────────────────────────────────────────

  @override
  Future<List<Prayer>> getDailyStatus() async {
    try {
      return await prayerService.fetchDayLogs(
        basePrayers: Prayer.defaultPrayers(),
      );
    } catch (e) {
      debugPrint('$_tag getDailyStatus error: $e');
      return Prayer.defaultPrayers();
    }
  }

  @override
  Future<List<Prayer>> logPrayer({
    required String prayerName,
    required bool completed,
    bool inJamaat = false,
    String location = 'home',
    String? status,
    String? reason,
    String? dateKey,
    bool? prayedJumah,
  }) async {
    final resolvedStatus = status ?? (completed ? 'on_time' : 'missed');
    try {
      await prayerService.upsertLog(
        prayerName: prayerName,
        status: resolvedStatus,
        inJamaat: inJamaat,
        reason: reason,
        dateKey: dateKey,
      );
    } catch (e) {
      debugPrint('$_tag logPrayer error: $e');
    }
    // Return updated day so PrayerBloc can refresh
    return getDailyStatus();
  }

  @override
  Future<Map<String, List<Prayer>>> getDetailedMonthHistory({
    required int year,
    required int month,
  }) async {
    try {
      return await prayerService.fetchMonthLogs(year: year, month: month);
    } catch (e) {
      debugPrint('$_tag getDetailedMonthHistory error: $e');
      return const {};
    }
  }

  // ── STUBBED: pending next phase ───────────────────────────────────────────

  @override
  Future<Streak> getStreak() async {
    try {
      return await prayerService.getStreak();
    } catch (e) {
      debugPrint('$_tag getStreak error: $e');
      return const Streak();
    }
  }

  @override
  Future<Streak> consumeProtectorToken({String? date}) async {
    try {
      return await prayerService.consumeProtectorToken(date: date);
    } catch (e) {
      debugPrint('$_tag consumeProtectorToken error: $e');
      return const Streak();
    }
  }

  @override
  Future<Map<String, int>> getWeeklyHistory({int days = 90}) async {
    try {
      return await prayerService.getWeeklyHistory(days: days);
    } catch (e) {
      debugPrint('$_tag getWeeklyHistory error: $e');
      return const {};
    }
  }

  @override
  Future<Map<String, int>> getReasonSummary() async {
    try {
      return await prayerService.getReasonSummary();
    } catch (e) {
      debugPrint('$_tag getReasonSummary error: $e');
      return const {};
    }
  }


  @override
  Future<List<Prayer>> setExcusedDay({
    required String date,
    String? reason,
    Set<String>? prayerNames,
  }) async {
    return prayerService.setExcusedDay(
      date: date,
      reason: reason,
      prayerNames: prayerNames,
    );
  }

  @override
  Future<List<Prayer>> clearExcusedDay({required String date}) async {
    return prayerService.clearExcusedDay(date: date);
  }

  @override
  Future<List<Prayer>> undoLastPrayerLog({
    String? prayerName,
    String? dateKey,
  }) async {
    if (prayerName == null) return const [];
    
    await prayerService.undoLastPrayerLog(
      prayerName: prayerName,
      dateKey: dateKey,
    );
    
    return prayerService.fetchDayLogs(
      dateKey: dateKey,
      basePrayers: Prayer.defaultPrayers(),
    );
  }

  @override
  Future<Map<String, dynamic>> getSyncMetadata() async => const {};

  @override
  Future<Map<String, dynamic>> pauseNotificationsForToday() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return const {'is_paused': false, 'paused': false};

    final now = TimeService.effectiveNow();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      await client.from('user_settings').upsert({
        'id': user.id,
        'pause_notifications_until': todayStr,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'id');
      return {'is_paused': true, 'paused': true};
    } catch (e) {
      debugPrint('$_tag pauseNotificationsForToday error: $e');
      return {'is_paused': false, 'paused': false};
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationsPauseStatus() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return const {'is_paused': false, 'paused': false};

    try {
      final response = await client
          .from('user_settings')
          .select('pause_notifications_until')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['pause_notifications_until'] != null) {
        final now = TimeService.effectiveNow();
        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final isPaused = response['pause_notifications_until'] == todayStr;
        return {'is_paused': isPaused, 'paused': isPaused};
      }
    } catch (e) {
      debugPrint('$_tag getNotificationsPauseStatus error: $e');
    }
    return const {'is_paused': false, 'paused': false};
  }

  @override
  Future<Map<String, dynamic>> resumeNotificationsForToday() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return const {'is_paused': false, 'paused': false};

    try {
      await client.from('user_settings').upsert({
        'id': user.id,
        'pause_notifications_until': null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'id');
      return {'is_paused': false, 'paused': false};
    } catch (e) {
      debugPrint('$_tag resumeNotificationsForToday error: $e');
      return {'is_paused': false, 'paused': false};
    }
  }
}