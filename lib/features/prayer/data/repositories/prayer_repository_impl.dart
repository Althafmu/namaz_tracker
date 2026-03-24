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
  Future<List<List<Prayer>>> getWeeklyHistory() async {
    try {
      final data = await remoteDataSource.getWeeklyHistory();
      return data.map<List<Prayer>>((dayData) {
        return PrayerModel.fromApiResponse(dayData as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
