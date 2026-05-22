import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/core/supabase/prayer_service.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/prayer.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/streak.dart';
import 'package:namaz_tracker/features/prayer/data/repositories/prayer_repository_impl.dart';

class FakePrayerService implements PrayerService {
  @override
  Future<void> upsertLog({
    required String prayerName,
    required String status,
    bool inJamaat = false,
    String? reason,
    String? dateKey,
  }) async {}

  @override
  Future<List<Prayer>> fetchDayLogs({String? dateKey, required List<Prayer> basePrayers}) async =>
      basePrayers;

  @override
  Future<Map<String, List<Prayer>>> fetchMonthLogs({required int year, required int month}) async =>
      const {};

  @override
  Future<Map<String, int>> getWeeklyHistory({int days = 90}) async => const {};

  @override
  Future<Map<String, int>> getReasonSummary() async => const {};

  @override
  Future<Streak> getStreak() async => const Streak();

  @override
  Future<Streak> consumeProtectorToken({String? date}) async => const Streak();

  @override
  Future<List<Prayer>> setExcusedDay({
    required String date,
    String? reason,
    Set<String>? prayerNames,
  }) async => const [];

  @override
  Future<List<Prayer>> clearExcusedDay({required String date}) async => const [];

  @override
  Future<void> undoLastPrayerLog({
    required String prayerName,
    String? dateKey,
  }) async {}
}

void main() {
  group('PrayerRepositoryImpl - Phase 3 Features', () {
    late PrayerRepositoryImpl repository;

    setUp(() {
      repository = PrayerRepositoryImpl(prayerService: FakePrayerService());
    });

    test('instantiates without error', () {
      expect(repository, isA<PrayerRepositoryImpl>());
    });
  });
}