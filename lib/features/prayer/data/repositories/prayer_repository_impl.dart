import 'package:dio/dio.dart';

import '../../../../core/errors/api_error.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_remote_data_source.dart';
import '../models/prayer_model.dart';
import '../models/streak_model.dart';

/// Concrete implementation of [PrayerRepository].
/// Calls the remote data source and maps the results to domain entities.
/// In offline mode, the BLoC's HydratedBloc handles local persistence.
///
/// Error Handling Strategy:
/// - Network failures (connection refused, timeout) → NetworkException
/// - Server errors (4xx, 5xx) → ServerException (with structured ApiError)
/// - BLoCs decide how to handle: use cached data, show error, or retry
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerRemoteDataSource remoteDataSource;

  PrayerRepositoryImpl({required this.remoteDataSource});

  /// Converts Dio errors to appropriate AppException types.
  ///
  /// Parses the standardized `{code, detail, field_errors}` error contract
  /// from the backend and attaches it to the [ServerException].
  Never _handleDioError(DioException e, String operation) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.unknown:
        throw NetworkException(
          'Network error during $operation: ${e.message}',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final apiError = ApiError.fromResponse(
          e.response?.data,
          statusCode: statusCode,
        );

        if (statusCode != null && statusCode >= 500) {
          throw ServerException(
            'Server error during $operation ($statusCode)',
            statusCode: statusCode,
            apiError: apiError,
            originalError: e,
          );
        } else if (statusCode == 404) {
          throw NoDataException(
            'No data found for $operation',
            originalError: e,
          );
        } else {
          throw ServerException(
            'Request failed during $operation ($statusCode)',
            statusCode: statusCode,
            apiError: apiError,
            originalError: e,
          );
        }
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        throw NetworkException(
          'Request failed during $operation: ${e.message}',
          originalError: e,
        );
    }
  }

  @override
  Future<List<Prayer>> getDailyStatus() async {
    try {
      final data = await remoteDataSource.getTodayLog();
      return PrayerModel.fromApiResponse(data);
    } on DioException catch (e) {
      _handleDioError(e, 'getDailyStatus');
    } catch (e) {
      throw NetworkException('Unexpected error during getDailyStatus', originalError: e);
    }
  }

  @override
  Future<List<Prayer>> logPrayer({
    required String prayerName,
    required bool completed,
    bool inJamaat = false,
    String location = 'home',
    String? status,
    String? reason,
    String? dateKey,
  }) async {
    try {
      final data = await remoteDataSource.logPrayer(
        prayerName: prayerName,
        completed: completed,
        inJamaat: inJamaat,
        location: location,
        status: status,
        reason: reason,
        dateKey: dateKey,
      );
      return PrayerModel.fromApiResponse(data);
    } on DioException catch (e) {
      _handleDioError(e, 'logPrayer');
    } catch (e) {
      throw NetworkException('Unexpected error during logPrayer', originalError: e);
    }
  }

  @override
  Future<Streak> getStreak() async {
    try {
      final data = await remoteDataSource.getStreak();
      return StreakModel.fromApiResponse(data);
    } on DioException catch (e) {
      _handleDioError(e, 'getStreak');
    } catch (e) {
      throw NetworkException('Unexpected error during getStreak', originalError: e);
    }
  }

  @override
  Future<Map<String, int>> getWeeklyHistory({int days = 90}) async {
    try {
      final response = await remoteDataSource.getWeeklyHistory(days: days);
      final results = response['results'] as List<dynamic>? ?? [];
      final Map<String, int> history = {};
      for (final dayData in results) {
        final json = dayData as Map<String, dynamic>;
        if (json['date'] != null && json['completed_count'] != null) {
          history[json['date'] as String] = json['completed_count'] as int;
        }
      }
      return history;
    } on DioException catch (e) {
      _handleDioError(e, 'getWeeklyHistory');
    } catch (e) {
      throw NetworkException('Unexpected error during getWeeklyHistory', originalError: e);
    }
  }

  @override
  Future<Map<String, List<Prayer>>> getDetailedMonthHistory({
    required int year,
    required int month,
  }) async {
    try {
      final response = await remoteDataSource.getDetailedMonthHistory(
        year: year,
        month: month,
      );
      final results = response['results'] as List<dynamic>? ?? [];
      final Map<String, List<Prayer>> result = {};
      for (final dayData in results) {
        final json = dayData as Map<String, dynamic>;
        final dateStr = json['date'] as String?;
        if (dateStr != null) {
          result[dateStr] = PrayerModel.fromApiResponse(json);
        }
      }
      // If there are more pages, fetch them and merge
      final totalPages = response['total_pages'] as int? ?? 1;
      if (totalPages > 1) {
        for (var p = 2; p <= totalPages; p++) {
          final pageResponse = await remoteDataSource.getDetailedMonthHistory(
            year: year,
            month: month,
            page: p,
          );
          final pageResults = pageResponse['results'] as List<dynamic>? ?? [];
          for (final dayData in pageResults) {
            final json = dayData as Map<String, dynamic>;
            final dateStr = json['date'] as String?;
            if (dateStr != null) {
              result[dateStr] = PrayerModel.fromApiResponse(json);
            }
          }
        }
      }
      return result;
    } on DioException catch (e) {
      _handleDioError(e, 'getDetailedMonthHistory');
    } catch (e) {
      throw NetworkException('Unexpected error during getDetailedMonthHistory', originalError: e);
    }
  }

  @override
  Future<Map<String, int>> getReasonSummary() async {
    try {
      final data = await remoteDataSource.getReasonSummary();
      final reasons = data['reasons'] as Map<String, dynamic>? ?? {};
      return reasons.map((key, value) => MapEntry(key, value as int));
    } on DioException catch (e) {
      _handleDioError(e, 'getReasonSummary');
    } catch (e) {
      throw NetworkException('Unexpected error during getReasonSummary', originalError: e);
    }
  }

  // ── Phase 2: Streak Freeze System ──

  @override
  Future<Streak> consumeProtectorToken({String? date}) async {
    try {
      final data = await remoteDataSource.consumeProtectorToken(date: date);
      // Response includes 'streak' object with updated token count
      final streakData = data['streak'] as Map<String, dynamic>? ?? data;
      return StreakModel.fromApiResponse(streakData);
    } on DioException catch (e) {
      _handleDioError(e, 'consumeProtectorToken');
    } catch (e) {
      throw NetworkException('Unexpected error during consumeProtectorToken', originalError: e);
    }
  }

  @override
  Future<List<Prayer>> setExcusedDay({
    required String date,
    String? reason,
  }) async {
    try {
      final data = await remoteDataSource.setExcusedDay(date: date, reason: reason);
      return PrayerModel.fromApiResponse(data);
    } on DioException catch (e) {
      _handleDioError(e, 'setExcusedDay');
    } catch (e) {
      throw NetworkException('Unexpected error during setExcusedDay', originalError: e);
    }
  }

  // ── Phase 3: New Backend Features ──

  @override
  Future<List<Prayer>> undoLastPrayerLog({
    String? prayerName,
    String? dateKey,
  }) async {
    try {
      final data = await remoteDataSource.undoLastPrayerLog(
        prayerName: prayerName,
        dateKey: dateKey,
      );
      return PrayerModel.fromApiResponse(data);
    } on DioException catch (e) {
      _handleDioError(e, 'undoLastPrayerLog');
    } catch (e) {
      throw NetworkException('Unexpected error during undoLastPrayerLog', originalError: e);
    }
  }

  @override
  Future<Map<String, dynamic>> getSyncMetadata() async {
    try {
      return await remoteDataSource.getSyncMetadata();
    } on DioException catch (e) {
      _handleDioError(e, 'getSyncMetadata');
    } catch (e) {
      throw NetworkException('Unexpected error during getSyncMetadata', originalError: e);
    }
  }

  @override
  Future<Map<String, dynamic>> pauseNotificationsForToday() async {
    try {
      return await remoteDataSource.pauseNotificationsForToday();
    } on DioException catch (e) {
      _handleDioError(e, 'pauseNotificationsForToday');
    } catch (e) {
      throw NetworkException('Unexpected error during pauseNotificationsForToday', originalError: e);
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationsPauseStatus() async {
    try {
      return await remoteDataSource.getNotificationsPauseStatus();
    } on DioException catch (e) {
      _handleDioError(e, 'getNotificationsPauseStatus');
    } catch (e) {
      throw NetworkException('Unexpected error during getNotificationsPauseStatus', originalError: e);
    }
  }
}
