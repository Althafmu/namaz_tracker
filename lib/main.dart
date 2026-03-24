import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/prayer/data/repositories/offline_queue_repository.dart';
import 'features/prayer/presentation/bloc/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/prayer_event.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc storage for offline persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  // Initialize dependency injection
  await initDependencies();

  // Initialize encrypted offline queue (non-blocking)
  try {
    await sl<OfflineQueueRepository>().initialize();
  } catch (e) {
    debugPrint('OfflineQueueRepository init failed: $e');
  }

  // Start offline sync listener
  sl<OfflineSyncService>().startListening();

  // Initialize notification plugin (non-blocking)
  try {
    await sl<NotificationService>().initialize();
  } catch (e) {
    debugPrint('NotificationService init failed: $e');
  }

  runApp(const NamazTrackerApp());
}

class NamazTrackerApp extends StatelessWidget {
  const NamazTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<PrayerBloc>()..add(const LoadDailyStatus())),
      ],
      child: MaterialApp.router(
        title: 'Namaz Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
