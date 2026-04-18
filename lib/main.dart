import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/session_coordinator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/prayer/data/repositories/offline_queue_repository.dart';
import 'features/prayer/presentation/bloc/prayer/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/prayer/prayer_event.dart';
import 'features/prayer/presentation/bloc/history/history_bloc.dart';
import 'features/prayer/presentation/bloc/stats/stats_bloc.dart';
import 'features/prayer/presentation/bloc/settings/settings_bloc.dart';
import 'features/prayer/presentation/bloc/settings/settings_state.dart';
import 'features/prayer/presentation/bloc/streak/streak_bloc.dart';
import 'features/prayer/presentation/bloc/streak/streak_event.dart';
import 'injection_container.dart';

/// Flag set when storage corruption is detected and wiped.
/// The app can check this to show a recovery notice to the user.
const String kStorageCorruptionFlag = 'storage_corruption_wiped';

/// Flag set when storage recovery was attempted.
const String kStorageRecoveryAttempted = 'storage_recovery_attempted';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc storage for offline persistence
  // With recovery attempt and user notification support.
  bool storageWasCorrupted = false;
  final docDir = await getApplicationDocumentsDirectory();
  final storageDir = HydratedStorageDirectory(docDir.path);

  try {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: storageDir,
    );
  } catch (e) {
    debugPrint('[Main] HydratedStorage corrupted: $e');
    storageWasCorrupted = true;

    // Attempt recovery: Try to preserve any readable data before wiping
    bool recovered = false;
    try {
      recovered = await _attemptStorageRecovery(docDir);
    } catch (recoveryError) {
      debugPrint('[Main] Recovery attempt failed: $recoveryError');
    }

    // If recovery failed, wipe corrupted data as last resort
    if (!recovered) {
      debugPrint('[Main] Wiping corrupted storage as last resort');
      await _wipeCorruptedStorage(docDir);
    }

    // Retry storage initialization
    try {
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: storageDir,
      );
      debugPrint('[Main] Storage reinitialized successfully');
    } catch (e) {
      debugPrint('[Main] CRITICAL: Failed to reinitialize storage: $e');
      // App cannot function without storage, but we'll let it run
      // with in-memory storage that won't persist
    }
  }

  // Store corruption flag for app to show user notice
  if (storageWasCorrupted) {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kStorageCorruptionFlag, true);
    } catch (_) {}
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

  // Initialize app router using injected blocs
  final appRouter = buildAppRouter(sl<AuthBloc>(), sl<SettingsBloc>());

  // Start the session coordinator to manage background data syncing
  sl<SessionCoordinator>();

  runApp(FalahApp(appRouter: appRouter));
}

/// Attempts to recover data from corrupted Hive storage.
/// Returns true if any data was successfully recovered.
Future<bool> _attemptStorageRecovery(Directory docDir) async {
  debugPrint('[Main] Attempting storage recovery...');
  bool anyRecovered = false;

  try {
    // Try to backup any readable .hive files before wiping
    final backupDir = Directory('${docDir.path}/hive_backup_${DateTime.now().millisecondsSinceEpoch}');
    await backupDir.create(recursive: true);

    for (final file in docDir.listSync()) {
      if (file is File && file.path.endsWith('.hive')) {
        try {
          // Try to read the file - if successful, it's partially recoverable
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) {
            final backupFile = File('${backupDir.path}/${file.uri.pathSegments.last}');
            await backupFile.writeAsBytes(bytes);
            debugPrint('[Main] Backed up: ${file.path}');
            anyRecovered = true;
          }
        } catch (e) {
          debugPrint('[Main] Could not read ${file.path}: $e');
        }
      }
    }

    if (anyRecovered) {
      debugPrint('[Main] Recovery backup created at: ${backupDir.path}');
      // Set flag so app can attempt restore later
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kStorageRecoveryAttempted, true);
    }
  } catch (e) {
    debugPrint('[Main] Recovery backup failed: $e');
  }

  return anyRecovered;
}

/// Wipes corrupted Hive storage files.
Future<void> _wipeCorruptedStorage(Directory docDir) async {
  try {
    for (final file in docDir.listSync()) {
      if (file.path.endsWith('.hive') || file.path.endsWith('.lock')) {
        await file.delete();
        debugPrint('[Main] Deleted corrupted file: ${file.path}');
      }
    }
  } catch (e) {
    debugPrint('[Main] Error wiping storage: $e');
  }
}

/// Call this from the app's first screen to check if storage was corrupted
/// and show appropriate user notification.
Future<void> checkAndClearStorageCorruptionFlag(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final wasCorrupted = prefs.getBool(kStorageCorruptionFlag) ?? false;
    final recoveryAttempted = prefs.getBool(kStorageRecoveryAttempted) ?? false;

    if (wasCorrupted) {
      // Clear the flag so we don't show the message again
      await prefs.remove(kStorageCorruptionFlag);

      // Show user notification (snackbar or dialog)
      if (context.mounted) {
        final message = recoveryAttempted
            ? 'App data was corrupted. A backup was created. Some data may need to be re-synced from the server.'
            : 'App data was corrupted and had to be reset. Your prayer history will sync from the server.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  } catch (_) {}
}

class FalahApp extends StatelessWidget {
  final GoRouter appRouter;
  const FalahApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<SettingsBloc>()),
        BlocProvider.value(value: sl<HistoryBloc>()),
        BlocProvider.value(value: sl<StatsBloc>()),
        BlocProvider(create: (_) => sl<StreakBloc>()..add(const LoadStreak())),
        BlocProvider(create: (_) => sl<PrayerBloc>()..add(const LoadDailyStatus())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
        builder: (context, settingsState) {

          ThemeMode currentThemeMode;
          if (settingsState.themeMode == 'dark') {
            currentThemeMode = ThemeMode.dark;
          } else if (settingsState.themeMode == 'light') {
            currentThemeMode = ThemeMode.light;
          } else {
            currentThemeMode = ThemeMode.system;
          }

          return MaterialApp.router(
            title: 'Falah: Prayer Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentThemeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
