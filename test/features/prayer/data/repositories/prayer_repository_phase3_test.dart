import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:namaz_tracker/core/errors/exceptions.dart';
import 'package:namaz_tracker/features/prayer/data/datasources/prayer_remote_data_source.dart';
import 'package:namaz_tracker/features/prayer/data/repositories/prayer_repository_impl.dart';

class MockPrayerRemoteDataSource extends Mock
    implements PrayerRemoteDataSource {}

void main() {
  late PrayerRepositoryImpl repository;
  late MockPrayerRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPrayerRemoteDataSource();
    repository = PrayerRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('PrayerRepositoryImpl - Phase 3 Features', () {
    group('undoLastPrayerLog', () {
      test('returns updated prayers on success', () async {
        final response = {
          'fajr': false,
          'dhuhr': false,
          'asr': false,
          'maghrib': false,
          'isha': false,
        };
        when(() => mockDataSource.undoLastPrayerLog())
            .thenAnswer((_) async => response);

        final result = await repository.undoLastPrayerLog();

        expect(result.length, 5);
        expect(result.every((p) => !p.isCompleted), true);
      });

      test('throws ServerException with API error on 400', () async {
        final requestOptions =
            RequestOptions(path: '/api/prayers/undo/');
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: requestOptions,
          response: Response(
            statusCode: 400,
            data: {
              'code': 'UNDO_NOT_AVAILABLE',
              'detail': 'No recent prayer log to undo.',
            },
            requestOptions: requestOptions,
          ),
        );
        when(() => mockDataSource.undoLastPrayerLog()).thenThrow(dioError);

        try {
          await repository.undoLastPrayerLog();
          fail('Expected ServerException');
        } on ServerException catch (e) {
          expect(e.apiError, isNotNull);
          expect(e.apiError!.code, 'UNDO_NOT_AVAILABLE');
          expect(e.userMessage, 'No recent prayer log to undo.');
        }
      });

      test('throws NetworkException on timeout', () async {
        final dioError = DioException(
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out',
          requestOptions: RequestOptions(path: '/api/prayers/undo/'),
        );
        when(() => mockDataSource.undoLastPrayerLog()).thenThrow(dioError);

        expect(
          () => repository.undoLastPrayerLog(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getSyncMetadata', () {
      test('returns metadata map on success', () async {
        final response = {
          'last_sync_at': '2026-04-14T10:00:00Z',
          'source': 'app',
          'has_conflict': false,
        };
        when(() => mockDataSource.getSyncMetadata())
            .thenAnswer((_) async => response);

        final result = await repository.getSyncMetadata();

        expect(result['last_sync_at'], '2026-04-14T10:00:00Z');
        expect(result['source'], 'app');
        expect(result['has_conflict'], false);
      });

      test('throws NetworkException on connection error', () async {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          message: 'No internet',
          requestOptions: RequestOptions(path: '/api/sync/metadata/'),
        );
        when(() => mockDataSource.getSyncMetadata()).thenThrow(dioError);

        expect(
          () => repository.getSyncMetadata(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('pauseNotificationsForToday', () {
      test('returns confirmation on success', () async {
        final response = {'is_paused': true, 'until': '2026-04-14T23:59:59Z'};
        when(() => mockDataSource.pauseNotificationsForToday())
            .thenAnswer((_) async => response);

        final result = await repository.pauseNotificationsForToday();

        expect(result['is_paused'], true);
      });

      test('throws ServerException on failure', () async {
        final requestOptions =
            RequestOptions(path: '/api/notifications/pause-today/');
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: requestOptions,
          response: Response(
            statusCode: 500,
            data: {'code': 'SERVER_ERROR', 'detail': 'Internal error.'},
            requestOptions: requestOptions,
          ),
        );
        when(() => mockDataSource.pauseNotificationsForToday())
            .thenThrow(dioError);

        expect(
          () => repository.pauseNotificationsForToday(),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getNotificationsPauseStatus', () {
      test('returns pause status on success', () async {
        final response = {'is_paused': false};
        when(() => mockDataSource.getNotificationsPauseStatus())
            .thenAnswer((_) async => response);

        final result = await repository.getNotificationsPauseStatus();

        expect(result['is_paused'], false);
      });
    });
  });
}
