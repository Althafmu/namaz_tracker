import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'features/prayer/data/datasources/prayer_remote_data_source.dart';
import 'features/prayer/data/repositories/prayer_repository_impl.dart';
import 'features/prayer/data/repositories/offline_queue_repository.dart';
import 'features/prayer/domain/repositories/prayer_repository.dart';
import 'core/services/notification_service.dart';
import 'core/services/notification_service_interface.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/prayer_scheduler_service.dart';
import 'features/prayer/domain/usecases/get_daily_status_usecase.dart';
import 'features/prayer/domain/usecases/get_streak_usecase.dart';
import 'features/prayer/domain/usecases/get_weekly_history_usecase.dart';
import 'features/prayer/domain/usecases/get_detailed_month_history_usecase.dart';
import 'features/prayer/domain/usecases/get_reason_summary_usecase.dart';
import 'features/prayer/domain/usecases/log_prayer_usecase.dart';
import 'features/prayer/presentation/bloc/prayer/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/settings/settings_bloc.dart';
import 'features/prayer/presentation/bloc/history/history_bloc.dart';
import 'features/prayer/presentation/bloc/stats/stats_bloc.dart';

import 'core/network/token_provider.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

final sl = GetIt.instance;

/// API base URL from --dart-define.
/// Build with: flutter run --dart-define=API_BASE_URL=https://your-server.com
/// SECURITY: No default URL is provided. The API URL MUST be specified at build time.
const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',  // Empty by default — forces explicit configuration
);

/// Validates that API_BASE_URL is configured.
void _validateBaseUrl() {
  if (_baseUrl.isEmpty) {
    throw AssertionError(
      'API_BASE_URL must be set at build time.\n'
      'Example: flutter run --dart-define=API_BASE_URL=https://your-server.com\n'
      'Or set it in your launch configuration or CI/CD pipeline.'
    );
  }
  if (!_baseUrl.startsWith('https://') && !_baseUrl.startsWith('http://')) {
    throw AssertionError(
      'API_BASE_URL must start with https:// or http://\n'
      'Got: $_baseUrl'
    );
  }
}

/// Initialize all dependencies.
Future<void> initDependencies() async {
  // Validate API URL before initializing any network dependencies
  _validateBaseUrl();

  // ── Core Services ──
  final tokenProvider = TokenProvider();
  await tokenProvider.loadTokens();
  sl.registerLazySingleton(() => tokenProvider);

  sl.registerLazySingleton(() => OfflineQueueRepository());
  // Register interface and implementation for NotificationService
  final notificationService = NotificationService();
  sl.registerLazySingleton<NotificationServiceInterface>(() => notificationService);
  sl.registerLazySingleton(() => notificationService);

  // ── External (Dio) ──
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // Certificate pinning — reject self-signed certs
  if (!kIsWeb) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        debugPrint('[CertPin] Rejected untrusted certificate for $host:$port');
        return false;
      };
      return client;
    };
  }

  // Auth interceptor: attach token + 401 refresh + logout
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = sl<TokenProvider>().token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401 &&
          !error.requestOptions.path.contains('/auth/token/refresh/')) {
        debugPrint('[Auth] 401 received — attempting token refresh');
        try {
          final authRepo = sl<AuthRepository>() as AuthRepositoryImpl;
          final newToken = await authRepo.refreshAccessToken();
          if (newToken != null) {
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          debugPrint('[Auth] Token refresh failed: $e');
        }
        debugPrint('[Auth] Refresh failed — triggering logout');
        try {
          sl<AuthBloc>().add(LogoutRequested());
        } catch (_) {}
      }
      return handler.next(error);
    },
  ));

  sl.registerLazySingleton<Dio>(() => dio);

  // ── Data Sources ──
  sl.registerLazySingleton<PrayerRemoteDataSource>(
    () => PrayerRemoteDataSource(dio: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(dio: sl()),
  );

  // ── Repositories ──
  sl.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenProvider: sl(),
    ),
  );

  // ── Use Cases ──
  sl.registerLazySingleton(() => LogPrayerUseCase(sl()));
  sl.registerLazySingleton(() => GetDailyStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetStreakUseCase(sl()));
  sl.registerLazySingleton(() => GetWeeklyHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetDetailedMonthHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetReasonSummaryUseCase(sl()));

  // ── Domain Services ──
  sl.registerLazySingleton(() => OfflineSyncService(
        queueRepository: sl(),
        logPrayerUseCase: sl(),
      ));
  sl.registerLazySingleton(() => PrayerSchedulerService(
        notificationService: sl(),
      ));

  // ── BLoC ──
  sl.registerLazySingleton(() => SettingsBloc(
        notificationService: sl(),
      ));

  // HistoryBloc and StatsBloc must be registered before PrayerBloc
  sl.registerLazySingleton(() => HistoryBloc(
        getDetailedMonthHistoryUseCase: sl(),
      ));

  sl.registerLazySingleton(() => StatsBloc(
        getReasonSummaryUseCase: sl(),
      ));

  sl.registerFactory(() => PrayerBloc(
        logPrayerUseCase: sl(),
        getDailyStatusUseCase: sl(),
        getStreakUseCase: sl(),
        offlineSyncService: sl(),
        prayerSchedulerService: sl(),
        notificationService: sl(),
        settingsBloc: sl(),
        historyBloc: sl(),
        statsBloc: sl(),
      ));

  sl.registerLazySingleton(() => AuthBloc(
        authRepository: sl(),
        tokenProvider: sl(),
      ));
}
