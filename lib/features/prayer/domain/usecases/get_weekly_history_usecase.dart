import '../repositories/prayer_repository.dart';

/// Use case to get weekly prayer history (date string -> completed count).
class GetWeeklyHistoryUseCase {
  final PrayerRepository repository;

  GetWeeklyHistoryUseCase(this.repository);

  Future<Map<String, int>> call({int days = 90}) {
    return repository.getWeeklyHistory(days: days);
  }
}
