import '../repositories/prayer_repository.dart';

/// Get the current pause-notifications-for-today status from the backend.
class GetNotificationsPauseStatusUseCase {
  final PrayerRepository repository;

  GetNotificationsPauseStatusUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getNotificationsPauseStatus();
  }
}
