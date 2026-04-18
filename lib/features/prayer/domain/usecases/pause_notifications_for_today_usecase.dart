import '../repositories/prayer_repository.dart';

/// Pause notifications for today via the backend.
class PauseNotificationsForTodayUseCase {
  final PrayerRepository repository;

  PauseNotificationsForTodayUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.pauseNotificationsForToday();
  }
}
