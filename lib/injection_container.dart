import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'features/prayer/data/datasources/prayer_remote_data_source.dart';
import 'features/prayer/data/repositories/prayer_repository_impl.dart';
import 'features/prayer/domain/repositories/prayer_repository.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_sync_service.dart';
import 'features/prayer/domain/usecases/get_daily_status_usecase.dart';
import 'features/prayer/domain/usecases/log_prayer_usecase.dart';
import 'features/prayer/presentation/bloc/prayer_bloc.dart';

import 'core/network/token_provider.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependencies.
Future<void> initDependencies() async {
  // ── External ──
  // ── Services ──
  // Register TokenProvider first so Dio can use it
  sl.registerLazySingleton(() => TokenProvider());
  sl.registerLazySingleton(() => OfflineSyncService(sl()));
  sl.registerLazySingleton(() => NotificationService());

  // ── External ──
  final dio = Dio(BaseOptions(
    baseUrl: 'https://web-production-f44da.up.railway.app', // Production Server
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = sl<TokenProvider>().token;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
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

  // ── BLoC ──
  sl.registerFactory(() => PrayerBloc(
        logPrayerUseCase: sl(),
        getDailyStatusUseCase: sl(),
        offlineSyncService: sl(),
        notificationService: sl(),
      ));
  sl.registerLazySingleton(() => AuthBloc(
        authRepository: sl(),
        tokenProvider: sl(),
      ));
}
