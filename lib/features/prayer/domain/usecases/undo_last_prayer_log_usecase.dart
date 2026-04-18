import '../entities/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Undo the last prayer log action.
class UndoLastPrayerLogUseCase {
  final PrayerRepository repository;

  UndoLastPrayerLogUseCase(this.repository);

  Future<List<Prayer>> call() async {
    return await repository.undoLastPrayerLog();
  }
}
