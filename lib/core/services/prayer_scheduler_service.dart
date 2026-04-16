import 'package:adhan/adhan.dart' hide Prayer;
import 'package:flutter/foundation.dart';

import 'notification_service.dart';
import 'prayer_time_service.dart';
import '../../features/prayer/domain/entities/prayer.dart';
import '../../features/prayer/presentation/bloc/settings/settings_state.dart';

/// Service that coordinates GPS location, prayer time calculation, and
/// notification scheduling. Caches coordinates to avoid the double-GPS-call
/// problem that previously added ~10s to cold start.
class PrayerSchedulerService {
  final NotificationService _notificationService;

  Coordinates? _cachedCoordinates;

  PrayerSchedulerService({required NotificationService notificationService})
    : _notificationService = notificationService;

  /// Fetch GPS coordinates once and cache them. Returns null if unavailable.
  Future<Coordinates?> fetchAndCacheCoordinates({
    double? lastLat,
    double? lastLng,
  }) async {
    final coords = await PrayerTimeService.getCurrentLocation();
    if (coords != null) {
      _cachedCoordinates = coords;
    } else if (lastLat != null && lastLng != null) {
      // Fall back to previously cached coordinates from state
      _cachedCoordinates = Coordinates(lastLat, lastLng);
    }
    return _cachedCoordinates;
  }

  /// Get the currently cached coordinates (may be null).
  Coordinates? get cachedCoordinates => _cachedCoordinates;

  /// Seed cached coordinates from persisted state (no GPS call).
  void seedCachedCoordinates(double? lat, double? lng) {
    if (lat != null && lng != null && _cachedCoordinates == null) {
      _cachedCoordinates = Coordinates(lat, lng);
    }
  }

  /// Cancels all scheduled prayer notifications.
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Recalculate prayer times using only cached coordinates (zero async wait).
  /// Returns updated prayer list, or the original list if no coords are cached.
  List<Prayer> recalculateWithCachedCoords({
    required List<Prayer> currentPrayers,
    required String methodName,
    required bool useHanafi,
    Map<String, int>? manualOffsets,
  }) {
    return calculatePrayerTimes(
      currentPrayers: currentPrayers,
      methodName: methodName,
      useHanafi: useHanafi,
      manualOffsets: manualOffsets,
    );
  }

  /// Calculate prayer time ranges using cached (or provided) coordinates.
  /// Returns the updated prayer list with time ranges merged in.
  List<Prayer> calculatePrayerTimes({
    required List<Prayer> currentPrayers,
    required String methodName,
    required bool useHanafi,
    Map<String, int>? manualOffsets,
    Coordinates? coordinatesOverride,
  }) {
    final coords = coordinatesOverride ?? _cachedCoordinates;
    if (coords == null) {
      debugPrint(
        '[PrayerScheduler] No coordinates available — keeping existing times',
      );
      return currentPrayers;
    }

    final timeRanges = PrayerTimeService.getPrayerTimeRanges(
      coordinates: coords,
      methodName: methodName,
      useHanafi: useHanafi,
      manualOffsets: manualOffsets,
    );

    return currentPrayers.map((prayer) {
      final details = timeRanges[prayer.name];
      if (details != null) {
        return prayer.copyWith(
          timeRange: details.range,
          baseTime: details.baseTime,
          offset: details.offset,
        );
      }
      return prayer;
    }).toList();
  }

  /// Schedule prayer notifications using cached coordinates.
  /// Returns the number of notifications scheduled.
  Future<int> scheduleNotifications(SettingsState settings) async {
    final coords = _cachedCoordinates;
    if (coords == null) {
      debugPrint(
        '[PrayerScheduler] No coordinates — skipping notification scheduling',
      );
      return 0;
    }

    if (!settings.notificationsPermitted &&
        !_notificationService.permissionsGranted) {
      debugPrint(
        '[PrayerScheduler] Permissions not granted — skipping notification scheduling',
      );
      return 0;
    }

    try {
      return await _notificationService.schedulePrayerNotifications(
        coordinates: coords,
        methodName: settings.calculationMethod,
        useHanafi: settings.useHanafi,
        prayerConfigs: settings.prayerConfigs,
        alarmSound: settings.alarmSound,
        manualOffsets: settings.manualOffsets,
        alarmDurationMinutes: settings.alarmDurationMinutes,
        excusedDays: settings.excusedDays,
      );
    } catch (e) {
      debugPrint('[PrayerScheduler] Failed to schedule notifications: $e');
      return 0;
    }
  }

  /// Single method for the bloc: fetch coords, calc times, schedule alarms.
  /// Returns (updatedPrayers, lat, lng) or null on total failure.
  Future<({List<Prayer> prayers, double? lat, double? lng})?>
  refreshPrayersAndAlarms({
    required List<Prayer> currentPrayers,
    required SettingsState settingsState,
    double? cachedLat,
    double? cachedLng,
    String? methodOverride,
    bool? hanafiOverride,
  }) async {
    final coords = await fetchAndCacheCoordinates(
      lastLat: cachedLat,
      lastLng: cachedLng,
    );

    final method = methodOverride ?? settingsState.calculationMethod;
    final hanafi = hanafiOverride ?? settingsState.useHanafi;

    final updatedPrayers = calculatePrayerTimes(
      currentPrayers: currentPrayers,
      methodName: method,
      useHanafi: hanafi,
      manualOffsets: settingsState.manualOffsets,
      coordinatesOverride: coords,
    );

    // Schedule notifications with the updated state overrides
    final newState = settingsState.copyWith(
      calculationMethod: method,
      useHanafi: hanafi,
    );
    await scheduleNotifications(newState);

    return (
      prayers: updatedPrayers,
      lat: coords?.latitude,
      lng: coords?.longitude,
    );
  }
}
