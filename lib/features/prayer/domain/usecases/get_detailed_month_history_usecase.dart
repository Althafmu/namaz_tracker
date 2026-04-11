import '../entities/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Use case to get detailed prayer history for a specific month.
/// Returns date string -> list of Prayer with full status/reason/inJamaat.
class GetDetailedMonthHistoryUseCase {
  final PrayerRepository repository;

  GetDetailedMonthHistoryUseCase(this.repository);

  Future<Map<String, List<Prayer>>> call({
    required int year,
    required int month,
  }) {
    return repository.getDetailedMonthHistory(year: year, month: month);
  }
}
