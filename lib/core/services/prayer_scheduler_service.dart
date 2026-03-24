import 'package:adhan/adhan.dart' hide Prayer;
import 'package:flutter/foundation.dart';

import 'notification_service.dart';
import 'prayer_time_service.dart';
import '../../features/prayer/domain/entities/prayer.dart';
import '../../features/prayer/presentation/bloc/prayer_state.dart';

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

  /// Calculate prayer time ranges using cached (or provided) coordinates.
  /// Returns the updated prayer list with time ranges merged in.
  List<Prayer> calculatePrayerTimes({
    required List<Prayer> currentPrayers,
    required String methodName,
    required bool useHanafi,
    Coordinates? coordinatesOverride,
  }) {
    final coords = coordinatesOverride ?? _cachedCoordinates;
    if (coords == null) {
      debugPrint('[PrayerScheduler] No coordinates available — keeping existing times');
      return currentPrayers;
    }

    final timeRanges = PrayerTimeService.getPrayerTimeRanges(
      coordinates: coords,
      methodName: methodName,
      useHanafi: useHanafi,
    );

    return currentPrayers.map((prayer) {
      final newRange = timeRanges[prayer.name];
      return newRange != null ? prayer.copyWith(timeRange: newRange) : prayer;
    }).toList();
  }

  /// Schedule prayer notifications using cached coordinates.
  /// Returns the number of notifications scheduled.
  Future<int> scheduleNotifications(PrayerState state) async {
    final coords = _cachedCoordinates;
    if (coords == null) {
      debugPrint('[PrayerScheduler] No coordinates — skipping notification scheduling');
      return 0;
    }

    try {
      return await _notificationService.schedulePrayerNotifications(
        coordinates: coords,
        methodName: state.calculationMethod,
        useHanafi: state.useHanafi,
        adhanAlerts: state.adhanAlerts,
        reminderAlerts: state.reminderAlerts,
        reminderMinutes: state.reminderMinutes,
        reminderIsBefore: state.reminderIsBefore,
      );
    } catch (e) {
      debugPrint('[PrayerScheduler] Failed to schedule notifications: $e');
      return 0;
    }
  }

  /// Single method for the bloc: fetch coords, calc times, schedule alarms.
  /// Returns (updatedPrayers, lat, lng) or null on total failure.
  Future<({List<Prayer> prayers, double? lat, double? lng})?> refreshPrayersAndAlarms({
    required List<Prayer> currentPrayers,
    required PrayerState state,
    String? methodOverride,
    bool? hanafiOverride,
  }) async {
    final coords = await fetchAndCacheCoordinates(
      lastLat: state.cachedLat,
      lastLng: state.cachedLng,
    );

    final method = methodOverride ?? state.calculationMethod;
    final hanafi = hanafiOverride ?? state.useHanafi;

    final updatedPrayers = calculatePrayerTimes(
      currentPrayers: currentPrayers,
      methodName: method,
      useHanafi: hanafi,
      coordinatesOverride: coords,
    );

    // Schedule notifications with the same coordinates
    await scheduleNotifications(state);

    return (
      prayers: updatedPrayers,
      lat: coords?.latitude,
      lng: coords?.longitude,
    );
  }
}
