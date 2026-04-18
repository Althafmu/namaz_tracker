import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:namaz_tracker/core/errors/exceptions.dart';
import 'package:namaz_tracker/features/prayer/data/datasources/prayer_remote_data_source.dart';
import 'package:namaz_tracker/features/prayer/data/repositories/prayer_repository_impl.dart';

class MockPrayerRemoteDataSource extends Mock implements PrayerRemoteDataSource {}

void main() {
  late PrayerRepositoryImpl repository;
  late MockPrayerRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPrayerRemoteDataSource();
    repository = PrayerRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('PrayerRepositoryImpl', () {
    group('getDailyStatus', () {
      test('returns list of prayers on success', () async {
        final response = {
          'fajr': true,
          'dhuhr': false,
          'asr': true,
          'maghrib': false,
          'isha': true,
        };
        when(() => mockDataSource.getTodayLog())
            .thenAnswer((_) async => response);

        final result = await repository.getDailyStatus();

        expect(result.length, 5);
        expect(result[0].isCompleted, true);
        expect(result[1].isCompleted, false);
      });

      test('throws NetworkException on connection error', () async {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
          requestOptions: RequestOptions(path: '/api/prayers/today/'),
        );
        when(() => mockDataSource.getTodayLog())
            .thenThrow(dioError);

        expect(
          () => repository.getDailyStatus(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('throws ServerException on 500 error', () async {
        final requestOptions = RequestOptions(path: '/api/prayers/today/');
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: requestOptions,
          response: Response(
            statusCode: 500,
            requestOptions: requestOptions,
          ),
        );
        when(() => mockDataSource.getTodayLog())
            .thenThrow(dioError);

        expect(
          () => repository.getDailyStatus(),
          throwsA(allOf(
            isA<ServerException>(),
            predicate<ServerException>((e) => e.statusCode == 500),
          )),
        );
      });

      test('throws ServerException with apiError on structured error response', () async {
        final requestOptions = RequestOptions(path: '/api/prayers/today/');
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: requestOptions,
          response: Response(
            statusCode: 400,
            data: {
              'code': 'PRAYER_ALREADY_LOGGED',
              'detail': 'This prayer has already been logged.',
              'field_errors': {},
            },
            requestOptions: requestOptions,
          ),
        );
        when(() => mockDataSource.getTodayLog())
            .thenThrow(dioError);

        try {
          await repository.getDailyStatus();
          fail('Expected ServerException');
        } on ServerException catch (e) {
          expect(e.apiError, isNotNull);
          expect(e.apiError!.code, 'PRAYER_ALREADY_LOGGED');
          expect(e.errorCode, 'PRAYER_ALREADY_LOGGED');
          expect(e.userMessage, 'This prayer has already been logged.');
        }
      });

      test('throws NoDataException on 404 error', () async {
        final requestOptions = RequestOptions(path: '/api/prayers/today/');
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: requestOptions,
          response: Response(
            statusCode: 404,
            requestOptions: requestOptions,
          ),
        );
        when(() => mockDataSource.getTodayLog())
            .thenThrow(dioError);

        expect(
          () => repository.getDailyStatus(),
          throwsA(isA<NoDataException>()),
        );
      });

      test('throws NetworkException on unexpected error', () async {
        when(() => mockDataSource.getTodayLog())
            .thenThrow(Exception('Unexpected'));

        expect(
          () => repository.getDailyStatus(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('logPrayer', () {
      test('returns updated prayers on success', () async {
        final response = {
          'fajr': true,
          'dhuhr': false,
          'asr': false,
          'maghrib': false,
          'isha': false,
        };
        when(() => mockDataSource.logPrayer(
          prayerName: 'fajr',
          completed: true,
          inJamaat: false,
          location: 'home',
          status: any(named: 'status'),
          reason: any(named: 'reason'),
          dateKey: any(named: 'dateKey'),
        )).thenAnswer((_) async => response);

        final result = await repository.logPrayer(
          prayerName: 'fajr',
          completed: true,
        );

        expect(result[0].isCompleted, true);
      });

      test('throws NetworkException on timeout', () async {
        final dioError = DioException(
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out',
          requestOptions: RequestOptions(path: '/api/prayers/log/'),
        );
        when(() => mockDataSource.logPrayer(
          prayerName: any(named: 'prayerName'),
          completed: any(named: 'completed'),
          inJamaat: any(named: 'inJamaat'),
          location: any(named: 'location'),
          status: any(named: 'status'),
          reason: any(named: 'reason'),
          dateKey: any(named: 'dateKey'),
        )).thenThrow(dioError);

        expect(
          () => repository.logPrayer(prayerName: 'fajr', completed: true),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getStreak', () {
      test('returns streak on success', () async {
        final response = {
          'current_streak': 7,
          'longest_streak': 14,
          'last_completed_date': '2026-04-14',
          'display_streak': 7,
        };
        when(() => mockDataSource.getStreak())
            .thenAnswer((_) async => response);

        final result = await repository.getStreak();

        expect(result.currentStreak, 7);
        expect(result.longestStreak, 14);
        expect(result.lastCompletedDate, '2026-04-14');
      });

      test('throws NetworkException on connection error', () async {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          message: 'No internet',
          requestOptions: RequestOptions(path: '/api/streak/'),
        );
        when(() => mockDataSource.getStreak())
            .thenThrow(dioError);

        expect(
          () => repository.getStreak(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getWeeklyHistory', () {
      test('returns history map on success', () async {
        final response = {
          'results': [
            {'date': '2026-04-14', 'completed_count': 5},
            {'date': '2026-04-13', 'completed_count': 4},
            {'date': '2026-04-12', 'completed_count': 3},
          ],
        };
        when(() => mockDataSource.getWeeklyHistory(days: any(named: 'days')))
            .thenAnswer((_) async => response);

        final result = await repository.getWeeklyHistory();

        expect(result.length, 3);
        expect(result['2026-04-14'], 5);
        expect(result['2026-04-13'], 4);
        expect(result['2026-04-12'], 3);
      });

      test('handles empty results', () async {
        final response = {'results': <dynamic>[]};
        when(() => mockDataSource.getWeeklyHistory(days: any(named: 'days')))
            .thenAnswer((_) async => response);

        final result = await repository.getWeeklyHistory();

        expect(result.isEmpty, true);
      });

      test('handles missing results key', () async {
        final response = <String, dynamic>{};
        when(() => mockDataSource.getWeeklyHistory(days: any(named: 'days')))
            .thenAnswer((_) async => response);

        final result = await repository.getWeeklyHistory();

        expect(result.isEmpty, true);
      });

      test('skips entries with null date or count', () async {
        final response = {
          'results': [
            {'date': '2026-04-14', 'completed_count': 5},
            {'date': null, 'completed_count': 3}, // should be skipped
            {'date': '2026-04-13', 'completed_count': null}, // should be skipped
          ],
        };
        when(() => mockDataSource.getWeeklyHistory(days: any(named: 'days')))
            .thenAnswer((_) async => response);

        final result = await repository.getWeeklyHistory();

        expect(result.length, 1);
        expect(result['2026-04-14'], 5);
      });
    });

    group('getDetailedMonthHistory', () {
      test('returns detailed history map on success', () async {
        final response = {
          'results': [
            {
              'date': '2026-04-14',
              'fajr': true,
              'dhuhr': false,
              'asr': true,
              'maghrib': false,
              'isha': true,
            },
          ],
          'total_pages': 1,
        };
        when(() => mockDataSource.getDetailedMonthHistory(
          year: any(named: 'year'),
          month: any(named: 'month'),
          page: any(named: 'page'),
        )).thenAnswer((_) async => response);

        final result = await repository.getDetailedMonthHistory(
          year: 2026,
          month: 4,
        );

        expect(result.containsKey('2026-04-14'), true);
        expect(result['2026-04-14']!.length, 5);
      });

      test('fetches multiple pages when needed', () async {
        final page1Response = {
          'results': [
            {'date': '2026-04-01', 'fajr': true},
          ],
          'total_pages': 2,
        };
        final page2Response = {
          'results': [
            {'date': '2026-04-02', 'fajr': false},
          ],
          'total_pages': 2,
        };

        when(() => mockDataSource.getDetailedMonthHistory(
          year: 2026,
          month: 4,
          page: 1,
        )).thenAnswer((_) async => page1Response);

        when(() => mockDataSource.getDetailedMonthHistory(
          year: 2026,
          month: 4,
          page: 2,
        )).thenAnswer((_) async => page2Response);

        final result = await repository.getDetailedMonthHistory(
          year: 2026,
          month: 4,
        );

        expect(result.length, 2);
        expect(result.containsKey('2026-04-01'), true);
        expect(result.containsKey('2026-04-02'), true);
      });
    });

    group('getReasonSummary', () {
      test('returns reason summary map on success', () async {
        final response = {
          'reasons': {
            'Work': 10,
            'Travel': 5,
            'Slept in': 3,
          },
        };
        when(() => mockDataSource.getReasonSummary())
            .thenAnswer((_) async => response);

        final result = await repository.getReasonSummary();

        expect(result.length, 3);
        expect(result['Work'], 10);
        expect(result['Travel'], 5);
        expect(result['Slept in'], 3);
      });

      test('handles empty reasons', () async {
        final response = {'reasons': <String, dynamic>{}};
        when(() => mockDataSource.getReasonSummary())
            .thenAnswer((_) async => response);

        final result = await repository.getReasonSummary();

        expect(result.isEmpty, true);
      });

      test('handles missing reasons key', () async {
        final response = <String, dynamic>{};
        when(() => mockDataSource.getReasonSummary())
            .thenAnswer((_) async => response);

        final result = await repository.getReasonSummary();

        expect(result.isEmpty, true);
      });
    });
  });
}