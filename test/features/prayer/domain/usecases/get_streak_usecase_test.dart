import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:namaz_tracker/features/prayer/domain/entities/streak.dart';
import 'package:namaz_tracker/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:namaz_tracker/features/prayer/domain/usecases/get_streak_usecase.dart';

class MockPrayerRepository extends Mock implements PrayerRepository {}

void main() {
  late GetStreakUseCase useCase;
  late MockPrayerRepository mockRepository;

  setUp(() {
    mockRepository = MockPrayerRepository();
    useCase = GetStreakUseCase(mockRepository);
  });

  group('GetStreakUseCase', () {
    test('calls repository.getStreak and returns result', () async {
      final expectedStreak = Streak(
        currentStreak: 7,
        longestStreak: 14,
        lastCompletedDate: '2026-04-14',
        displayStreak: 7,
      );
      when(() => mockRepository.getStreak())
          .thenAnswer((_) async => expectedStreak);

      final result = await useCase();

      expect(result, expectedStreak);
      verify(() => mockRepository.getStreak()).called(1);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.getStreak())
          .thenThrow(Exception('Network error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}