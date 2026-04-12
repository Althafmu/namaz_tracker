import '../entities/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Use case to log a prayer as completed/uncompleted.
class LogPrayerUseCase {
  final PrayerRepository repository;

  LogPrayerUseCase(this.repository);

  Future<List<Prayer>> call({
    required String prayerName,
    required bool completed,
    bool inJamaat = false,
    String location = 'home',
    String? status,
    String? reason,
    String? dateKey,
  }) {
    return repository.logPrayer(
      prayerName: prayerName,
      completed: completed,
      inJamaat: inJamaat,
      location: location,
      status: status,
      reason: reason,
      dateKey: dateKey,
    );
  }
}
