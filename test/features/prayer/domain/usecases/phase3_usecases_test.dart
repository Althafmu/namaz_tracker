import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/prayer.dart';
import 'package:namaz_tracker/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:namaz_tracker/features/prayer/domain/usecases/undo_last_prayer_log_usecase.dart';
import 'package:namaz_tracker/features/prayer/domain/usecases/get_sync_metadata_usecase.dart';
import 'package:namaz_tracker/features/prayer/domain/usecases/pause_notifications_for_today_usecase.dart';
import 'package:namaz_tracker/features/prayer/domain/usecases/get_notifications_pause_status_usecase.dart';

class MockPrayerRepository extends Mock implements PrayerRepository {}

void main() {
  late MockPrayerRepository mockRepository;

  setUp(() {
    mockRepository = MockPrayerRepository();
  });

  group('UndoLastPrayerLogUseCase', () {
    late UndoLastPrayerLogUseCase useCase;

    setUp(() {
      useCase = UndoLastPrayerLogUseCase(mockRepository);
    });

    test('calls repository.undoLastPrayerLog and returns result', () async {
      final expectedPrayers = Prayer.defaultPrayers();
      when(() => mockRepository.undoLastPrayerLog())
          .thenAnswer((_) async => expectedPrayers);

      final result = await useCase();

      expect(result, expectedPrayers);
      verify(() => mockRepository.undoLastPrayerLog()).called(1);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.undoLastPrayerLog())
          .thenThrow(Exception('Network error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });

  group('GetSyncMetadataUseCase', () {
    late GetSyncMetadataUseCase useCase;

    setUp(() {
      useCase = GetSyncMetadataUseCase(mockRepository);
    });

    test('calls repository.getSyncMetadata and returns result', () async {
      final expectedData = {
        'last_sync_at': '2026-04-14T10:00:00Z',
        'source': 'app',
      };
      when(() => mockRepository.getSyncMetadata())
          .thenAnswer((_) async => expectedData);

      final result = await useCase();

      expect(result, expectedData);
      verify(() => mockRepository.getSyncMetadata()).called(1);
    });
  });

  group('PauseNotificationsForTodayUseCase', () {
    late PauseNotificationsForTodayUseCase useCase;

    setUp(() {
      useCase = PauseNotificationsForTodayUseCase(mockRepository);
    });

    test('calls repository.pauseNotificationsForToday and returns result',
        () async {
      final expectedData = {'is_paused': true};
      when(() => mockRepository.pauseNotificationsForToday())
          .thenAnswer((_) async => expectedData);

      final result = await useCase();

      expect(result, expectedData);
      verify(() => mockRepository.pauseNotificationsForToday()).called(1);
    });
  });

  group('GetNotificationsPauseStatusUseCase', () {
    late GetNotificationsPauseStatusUseCase useCase;

    setUp(() {
      useCase = GetNotificationsPauseStatusUseCase(mockRepository);
    });

    test('calls repository.getNotificationsPauseStatus and returns result',
        () async {
      final expectedData = {'is_paused': false};
      when(() => mockRepository.getNotificationsPauseStatus())
          .thenAnswer((_) async => expectedData);

      final result = await useCase();

      expect(result, expectedData);
      verify(() => mockRepository.getNotificationsPauseStatus()).called(1);
    });
  });
}
