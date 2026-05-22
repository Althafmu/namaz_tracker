import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase/prayer_service.dart';
import 'core/supabase/supabase_prayer_service.dart';
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
import 'features/prayer/domain/usecases/consume_protector_token_usecase.dart';
import 'features/prayer/domain/usecases/set_excused_day_usecase.dart';
import 'features/prayer/domain/usecases/clear_excused_day_usecase.dart';
import 'features/prayer/domain/usecases/undo_last_prayer_log_usecase.dart';
import 'features/prayer/domain/usecases/get_sync_metadata_usecase.dart';
import 'features/prayer/domain/usecases/pause_notifications_for_today_usecase.dart';
import 'features/prayer/domain/usecases/get_notifications_pause_status_usecase.dart';
import 'features/prayer/domain/usecases/resume_notifications_for_today_usecase.dart';
import 'features/prayer/data/datasources/sunnah_remote_data_source.dart';

import 'features/groups/data/datasources/group_remote_datasource.dart';
import 'features/groups/data/repositories/group_repository_impl.dart';
import 'features/groups/domain/repositories/group_repository.dart';
import 'features/groups/presentation/bloc/group_dashboard_bloc.dart';
import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/groups/services/group_activity_notification_service.dart';
import 'core/notifications/notification_coordinator.dart';
import 'features/prayer/presentation/bloc/prayer/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/settings/settings_bloc.dart';
import 'features/prayer/presentation/bloc/history/history_bloc.dart';
import 'features/prayer/presentation/bloc/stats/stats_bloc.dart';
import 'features/prayer/presentation/bloc/streak/streak_bloc.dart';
import 'features/prayer/presentation/bloc/sunnah/sunnah_bloc.dart';
import 'core/services/session_coordinator.dart';

import 'core/network/token_provider.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependencies.
Future<void> initDependencies() async {
  debugPrint('[DI] initDependencies — Supabase mode.');

  // ── Supabase ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ── Core Services ─────────────────────────────────────────────────────────
  final tokenProvider = TokenProvider();
  await tokenProvider.loadTokens();
  sl.registerLazySingleton<TokenProvider>(() => tokenProvider);

  sl.registerLazySingleton<OfflineQueueRepository>(() => OfflineQueueRepository());

  final notificationService = NotificationService();
  sl.registerLazySingleton<NotificationServiceInterface>(() => notificationService);
  sl.registerLazySingleton<NotificationService>(() => notificationService);

  // ── Supabase Services ─────────────────────────────────────────────────────
  sl.registerLazySingleton<PrayerService>(
    () => SupabasePrayerService(sl<SupabaseClient>()),
  );

  // ── Data Sources (stubbed — no Dio/Django calls) ──────────────────────────
  // AuthRemoteDataSource: Google Sign-In is live; everything else stubbed.
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );

  sl.registerLazySingleton<GroupRemoteDataSource>(
    () => GroupRemoteDataSource(client: sl<SupabaseClient>()),
  );

  // ── Group Support Services ─────────────────────────────────────────────────
  sl.registerLazySingleton<GroupActivityNotificationService>(
    () => GroupActivityNotificationService(dataSource: sl<GroupRemoteDataSource>()),
  );

  sl.registerLazySingleton<NotificationCoordinator>(
    () => NotificationCoordinator(activityService: sl<GroupActivityNotificationService>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(prayerService: sl<PrayerService>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      tokenProvider: sl<TokenProvider>(),
    ),
  );

  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(sl<GroupRemoteDataSource>()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LogPrayerUseCase>(
    () => LogPrayerUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<GetDailyStatusUseCase>(
    () => GetDailyStatusUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<GetStreakUseCase>(
    () => GetStreakUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<GetWeeklyHistoryUseCase>(
    () => GetWeeklyHistoryUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<GetDetailedMonthHistoryUseCase>(
    () => GetDetailedMonthHistoryUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<GetReasonSummaryUseCase>(
    () => GetReasonSummaryUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<ConsumeProtectorTokenUseCase>(
    () => ConsumeProtectorTokenUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<SetExcusedDayUseCase>(
    () => SetExcusedDayUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<ClearExcusedDayUseCase>(
    () => ClearExcusedDayUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<UndoLastPrayerLogUseCase>(
    () => UndoLastPrayerLogUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<GetSyncMetadataUseCase>(
    () => GetSyncMetadataUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<PauseNotificationsForTodayUseCase>(
    () => PauseNotificationsForTodayUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<GetNotificationsPauseStatusUseCase>(
    () => GetNotificationsPauseStatusUseCase(sl<PrayerRepository>()),
  );
  sl.registerLazySingleton<ResumeNotificationsForTodayUseCase>(
    () => ResumeNotificationsForTodayUseCase(sl<PrayerRepository>()),
  );

  // ── Domain Services ───────────────────────────────────────────────────────
  sl.registerLazySingleton<OfflineSyncService>(
    () => OfflineSyncService(
      queueRepository: sl<OfflineQueueRepository>(),
      logPrayerUseCase: sl<LogPrayerUseCase>(),
    ),
  );
  sl.registerLazySingleton<PrayerSchedulerService>(
    () => PrayerSchedulerService(notificationService: sl<NotificationService>()),
  );

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SunnahRemoteDataSource>(
    () => SunnahRemoteDataSource(client: sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<SunnahBloc>(
    () => SunnahBloc(remoteDataSource: sl<SunnahRemoteDataSource>()),
  );

  sl.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(
      notificationService: sl<NotificationService>(),
      authRepository: sl<AuthRepository>(),
      pauseNotificationsForTodayUseCase: sl<PauseNotificationsForTodayUseCase>(),
      getNotificationsPauseStatusUseCase: sl<GetNotificationsPauseStatusUseCase>(),
      resumeNotificationsForTodayUseCase: sl<ResumeNotificationsForTodayUseCase>(),
    ),
  );

  sl.registerLazySingleton<HistoryBloc>(
    () => HistoryBloc(getDetailedMonthHistoryUseCase: sl<GetDetailedMonthHistoryUseCase>()),
  );

  sl.registerLazySingleton<StatsBloc>(
    () => StatsBloc(getReasonSummaryUseCase: sl<GetReasonSummaryUseCase>()),
  );

  sl.registerLazySingleton<StreakBloc>(
    () => StreakBloc(
      getStreakUseCase: sl<GetStreakUseCase>(),
      consumeProtectorTokenUseCase: sl<ConsumeProtectorTokenUseCase>(),
      setExcusedDayUseCase: sl<SetExcusedDayUseCase>(),
      historyBloc: sl<HistoryBloc>(),
    ),
  );

  sl.registerFactory<PrayerBloc>(
    () => PrayerBloc(
      logPrayerUseCase: sl<LogPrayerUseCase>(),
      getDailyStatusUseCase: sl<GetDailyStatusUseCase>(),
      clearExcusedDayUseCase: sl<ClearExcusedDayUseCase>(),
      undoLastPrayerLogUseCase: sl<UndoLastPrayerLogUseCase>(),
      offlineSyncService: sl<OfflineSyncService>(),
      prayerSchedulerService: sl<PrayerSchedulerService>(),
      notificationService: sl<NotificationService>(),
      settingsBloc: sl<SettingsBloc>(),
      historyBloc: sl<HistoryBloc>(),
      statsBloc: sl<StatsBloc>(),
    ),
  );

  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepository: sl<AuthRepository>(),
      tokenProvider: sl<TokenProvider>(),
    ),
  );

  sl.registerLazySingleton<SessionCoordinator>(
    () => SessionCoordinator(
      authBloc: sl<AuthBloc>(),
      settingsBloc: sl<SettingsBloc>(),
      authRepository: sl<AuthRepository>(),
      prayerSchedulerService: sl<PrayerSchedulerService>(),
    ),
  );

  sl.registerFactory<GroupDashboardBloc>(
    () => GroupDashboardBloc(repository: sl<GroupRepository>()),
  );

  sl.registerFactory<GroupsBloc>(
    () => GroupsBloc(repository: sl<GroupRepository>()),
  );
}
