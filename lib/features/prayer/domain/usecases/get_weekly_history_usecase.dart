import '../entities/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Use case to get weekly prayer history (list of daily prayer lists).
class GetWeeklyHistoryUseCase {
  final PrayerRepository repository;

  GetWeeklyHistoryUseCase(this.repository);

  Future<List<List<Prayer>>> call() {
    return repository.getWeeklyHistory();
  }
}
