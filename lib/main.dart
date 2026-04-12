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
import 'features/prayer/presentation/bloc/prayer/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/prayer/prayer_event.dart';
import 'features/prayer/presentation/bloc/settings/settings_bloc.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc storage for offline persistence
  // If storage is corrupted (e.g. after an upgrade), clear it and retry.
  final docDir = await getApplicationDocumentsDirectory();
  final storageDir = HydratedStorageDirectory(docDir.path);
  try {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: storageDir,
    );
  } catch (e) {
    debugPrint('[Main] HydratedStorage corrupted, wiping and retrying: $e');
    // Delete all .hive files in the documents dir to clear corrupted data
    try {
      final dir = docDir;
      if (dir.existsSync()) {
        for (final file in dir.listSync()) {
          if (file.path.endsWith('.hive') || file.path.endsWith('.lock')) {
            file.deleteSync();
          }
        }
      }
    } catch (_) {}
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: storageDir,
    );
  }

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

  runApp(const FalahApp());
}

class FalahApp extends StatelessWidget {
  const FalahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<SettingsBloc>()),
        BlocProvider(create: (_) => sl<PrayerBloc>()..add(const LoadDailyStatus())),
      ],
      child: MaterialApp.router(
        title: 'Falah: Prayer Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
