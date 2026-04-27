import '../repositories/prayer_repository.dart';

/// Resume (unpause) notifications for today via the backend.
class ResumeNotificationsForTodayUseCase {
  final PrayerRepository repository;

  ResumeNotificationsForTodayUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.resumeNotificationsForToday();
  }
}