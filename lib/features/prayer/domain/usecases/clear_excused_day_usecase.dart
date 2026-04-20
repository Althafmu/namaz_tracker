import '../entities/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Use case to clear an excused day and resume normal prayer logging.
class ClearExcusedDayUseCase {
  final PrayerRepository repository;

  ClearExcusedDayUseCase(this.repository);

  Future<List<Prayer>> call({required String date}) {
    return repository.clearExcusedDay(date: date);
  }
}
