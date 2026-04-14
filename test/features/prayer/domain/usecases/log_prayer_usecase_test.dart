import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/prayer.dart';
import 'package:namaz_tracker/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:namaz_tracker/features/prayer/domain/usecases/log_prayer_usecase.dart';

class MockPrayerRepository extends Mock implements PrayerRepository {}

void main() {
  late LogPrayerUseCase useCase;
  late MockPrayerRepository mockRepository;

  setUp(() {
    mockRepository = MockPrayerRepository();
    useCase = LogPrayerUseCase(mockRepository);
  });

  group('LogPrayerUseCase', () {
    test('calls repository.logPrayer with correct parameters', () async {
      final expectedPrayers = Prayer.defaultPrayers();
      when(() => mockRepository.logPrayer(
        prayerName: 'Fajr',
        completed: true,
        inJamaat: false,
        location: 'home',
        status: any(named: 'status'),
        reason: any(named: 'reason'),
        dateKey: any(named: 'dateKey'),
      )).thenAnswer((_) async => expectedPrayers);

      final result = await useCase(
        prayerName: 'Fajr',
        completed: true,
      );

      expect(result, expectedPrayers);
      verify(() => mockRepository.logPrayer(
        prayerName: 'Fajr',
        completed: true,
        inJamaat: false,
        location: 'home',
        status: null,
        reason: null,
        dateKey: null,
      )).called(1);
    });

    test('passes all optional parameters to repository', () async {
      final expectedPrayers = Prayer.defaultPrayers();
      when(() => mockRepository.logPrayer(
        prayerName: any(named: 'prayerName'),
        completed: any(named: 'completed'),
        inJamaat: any(named: 'inJamaat'),
        location: any(named: 'location'),
        status: any(named: 'status'),
        reason: any(named: 'reason'),
        dateKey: any(named: 'dateKey'),
      )).thenAnswer((_) async => expectedPrayers);

      await useCase(
        prayerName: 'Dhuhr',
        completed: true,
        inJamaat: true,
        location: 'mosque',
        status: 'on_time',
        reason: 'Work',
        dateKey: '2026-04-14',
      );

      verify(() => mockRepository.logPrayer(
        prayerName: 'Dhuhr',
        completed: true,
        inJamaat: true,
        location: 'mosque',
        status: 'on_time',
        reason: 'Work',
        dateKey: '2026-04-14',
      )).called(1);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.logPrayer(
        prayerName: any(named: 'prayerName'),
        completed: any(named: 'completed'),
        inJamaat: any(named: 'inJamaat'),
        location: any(named: 'location'),
        status: any(named: 'status'),
        reason: any(named: 'reason'),
        dateKey: any(named: 'dateKey'),
      )).thenThrow(Exception('Network error'));

      expect(
        () => useCase(prayerName: 'Fajr', completed: true),
        throwsA(isA<Exception>()),
      );
    });
  });
}