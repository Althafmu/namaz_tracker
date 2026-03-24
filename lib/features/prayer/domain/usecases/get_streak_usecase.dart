import '../entities/streak.dart';
import '../repositories/prayer_repository.dart';

/// Use case to get the user's current streak info.
class GetStreakUseCase {
  final PrayerRepository repository;

  GetStreakUseCase(this.repository);

  Future<Streak> call() {
    return repository.getStreak();
  }
}
