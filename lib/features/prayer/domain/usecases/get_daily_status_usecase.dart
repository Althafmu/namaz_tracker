import '../entities/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Use case to get today's prayer status.
class GetDailyStatusUseCase {
  final PrayerRepository repository;

  GetDailyStatusUseCase(this.repository);

  Future<List<Prayer>> call() {
    return repository.getDailyStatus();
  }
}
