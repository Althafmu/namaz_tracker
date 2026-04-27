import '../entities/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Use case to mark a day as excused (travel, sickness, women's period).
///
/// This is part of the Phase 2 Excused Mode system.
/// Excused days freeze the streak and are excluded from analytics.
class SetExcusedDayUseCase {
  final PrayerRepository repository;

  SetExcusedDayUseCase(this.repository);

  /// Mark a day as excused.
  ///
  /// [date] - The date to mark as excused (required).
  /// [reason] - Optional reason (travel, sickness, period, etc.).
  /// [prayerNames] - Optional set of prayer names to mark as excused.
  ///                 If null, all remaining (non-logged) prayers are marked excused.
  /// Returns the updated prayer logs for that day.
  Future<List<Prayer>> call({
    required String date,
    String? reason,
    Set<String>? prayerNames,
  }) {
    return repository.setExcusedDay(date: date, reason: reason, prayerNames: prayerNames);
  }
}