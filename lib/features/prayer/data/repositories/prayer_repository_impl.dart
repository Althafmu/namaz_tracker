import '../../domain/entities/prayer.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_remote_data_source.dart';
import '../models/prayer_model.dart';
import '../models/streak_model.dart';

/// Concrete implementation of [PrayerRepository].
/// Calls the remote data source and maps the results to domain entities.
/// In offline mode, the BLoC's HydratedBloc handles local persistence.
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerRemoteDataSource remoteDataSource;

  PrayerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Prayer>> getDailyStatus() async {
    try {
      final data = await remoteDataSource.getTodayLog();
      return PrayerModel.fromApiResponse(data);
    } catch (e) {
      // Offline fallback — return defaults, BLoC state has the real data
      return Prayer.defaultPrayers();
    }
  }

  @override
  Future<List<Prayer>> logPrayer({
    required String prayerName,
    required bool completed,
    bool inJamaat = false,
    String location = 'home',
  }) async {
    try {
      final data = await remoteDataSource.logPrayer(
        prayerName: prayerName,
        completed: completed,
        inJamaat: inJamaat,
        location: location,
      );
      return PrayerModel.fromApiResponse(data);
    } catch (e) {
      // Offline — return empty, BLoC handles optimistic update
      rethrow;
    }
  }

  @override
  Future<Streak> getStreak() async {
    try {
      final data = await remoteDataSource.getStreak();
      return StreakModel.fromApiResponse(data);
    } catch (e) {
      return const Streak();
    }
  }

  @override
  Future<Map<String, int>> getWeeklyHistory({int days = 90}) async {
    try {
      final data = await remoteDataSource.getWeeklyHistory(days: days);
      final Map<String, int> history = {};
      for (final dayData in data) {
        final json = dayData as Map<String, dynamic>;
        if (json['date'] != null && json['completed_count'] != null) {
          history[json['date'] as String] = json['completed_count'] as int;
        }
      }
      return history;
    } catch (e) {
      return {};
    }
  }
}
