import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

/// Service that calculates real prayer times using the adhan library
/// and the device's GPS location.
class PrayerTimeService {
  /// Available calculation methods mapped to human-readable names.
  static const Map<String, CalculationMethod> calculationMethods = {
    'ISNA': CalculationMethod.north_america,
    'MWL': CalculationMethod.muslim_world_league,
    'Egyptian': CalculationMethod.egyptian,
    'Umm Al-Qura': CalculationMethod.umm_al_qura,
    'Karachi': CalculationMethod.karachi,
    'Dubai': CalculationMethod.dubai,
    'Kuwait': CalculationMethod.kuwait,
    'Qatar': CalculationMethod.qatar,
    'Singapore': CalculationMethod.singapore,
    'Tehran': CalculationMethod.tehran,
    'Turkey': CalculationMethod.turkey,
  };

  /// Get the current device location.
  /// Returns null if permission is denied or location unavailable.
  /// Finding #8: No longer silently falls back to a hardcoded location.
  static Future<Coordinates?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      await Geolocator.openLocationSettings();
      // Re-check after user returns from settings
      await Future.delayed(const Duration(seconds: 2));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) {
      // Open app settings so user can manually grant location
      await Geolocator.openAppSettings();
      // Re-check after user returns
      await Future.delayed(const Duration(seconds: 2));
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return Coordinates(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  /// Determines the most appropriate calculation method from coordinates.
  ///
  /// Uses geographic bounding boxes to pick the regional standard:
  /// - Indian Subcontinent (India, Pakistan, Bangladesh) → Karachi
  /// - Saudi Arabia / Gulf States → Umm Al-Qura
  /// - Egypt / North Africa → Egyptian
  /// - Southeast Asia (Malaysia, Indonesia, Singapore area) → Singapore
  /// - Iran → Tehran
  /// - Turkey → Turkey
  /// - Kuwait → Kuwait
  /// - Qatar → Qatar
  /// - Dubai / UAE → Dubai
  /// - Rest of world (default) → Muslim World League
  static String methodFromCoordinates(double lat, double lng) {
    // Indian Subcontinent: India, Pakistan, Bangladesh, Sri Lanka, Nepal
    if (lat >= 6.0 && lat <= 37.5 && lng >= 61.0 && lng <= 97.5) {
      return 'Karachi';
    }
    // Saudi Arabia
    if (lat >= 16.0 && lat <= 32.5 && lng >= 36.5 && lng <= 55.5) {
      return 'Umm Al-Qura';
    }
    // Egypt
    if (lat >= 22.0 && lat <= 31.7 && lng >= 25.0 && lng <= 37.0) {
      return 'Egyptian';
    }
    // Southeast Asia (Indonesia, Malaysia, Singapore, Philippines area)
    if (lat >= -10.0 && lat <= 20.0 && lng >= 95.0 && lng <= 141.0) {
      return 'Singapore';
    }
    // Iran
    if (lat >= 25.0 && lat <= 40.0 && lng >= 44.0 && lng <= 64.0) {
      return 'Tehran';
    }
    // Turkey
    if (lat >= 36.0 && lat <= 42.5 && lng >= 26.0 && lng <= 45.0) {
      return 'Turkey';
    }
    // Kuwait
    if (lat >= 28.5 && lat <= 30.1 && lng >= 46.5 && lng <= 48.5) {
      return 'Kuwait';
    }
    // Qatar
    if (lat >= 24.5 && lat <= 26.2 && lng >= 50.7 && lng <= 51.7) {
      return 'Qatar';
    }
    // UAE / Dubai
    if (lat >= 22.6 && lat <= 26.1 && lng >= 51.6 && lng <= 56.5) {
      return 'Dubai';
    }
    // Default: Muslim World League (global standard)
    return 'MWL';
  }

  /// Base method to get calculation parameters with safety block and user offsets applied.
  static CalculationParameters _getAdjustedParams(
    String methodName,
    bool useHanafi,
    Map<String, int>? manualOffsets,
  ) {
    final method = calculationMethods[methodName] ?? CalculationMethod.muslim_world_league;
    final params = method.getParameters();
    params.madhab = useHanafi ? Madhab.hanafi : Madhab.shafi;

    // Standard Kochi 1-minute safety block combined with user manual offsets
    params.adjustments.fajr = 1 + (manualOffsets?['Fajr'] ?? 0);
    params.adjustments.sunrise = 1 + (manualOffsets?['Sunrise'] ?? 0);
    params.adjustments.dhuhr = 0 + (manualOffsets?['Dhuhr'] ?? 0);
    params.adjustments.asr = 1 + (manualOffsets?['Asr'] ?? 0);
    params.adjustments.maghrib = 1 + (manualOffsets?['Maghrib'] ?? 0);
    params.adjustments.isha = 1 + (manualOffsets?['Isha'] ?? 0);

    return params;
  }

  /// Calculate today's prayer times.
  ///
  /// [coordinates] — user's lat/lng
  /// [methodName] — one of the keys in [calculationMethods] (default: 'MWL')
  /// [useHanafi] — if true, uses Hanafi madhab for Asr (default: false = Shafi)
  /// [manualOffsets] — optional user-defined minute offsets
  static PrayerTimes calculateTimes({
    required Coordinates coordinates,
    String methodName = 'MWL',
    bool useHanafi = false,
    Map<String, int>? manualOffsets,
  }) {
    final params = _getAdjustedParams(methodName, useHanafi, manualOffsets);
    return PrayerTimes.today(coordinates, params);
  }

  /// Calculate prayer times for a specific date (useful for pre-scheduling alarms).
  static PrayerTimes calculateTimesForDate({
    required Coordinates coordinates,
    required DateTime date,
    String methodName = 'MWL',
    bool useHanafi = false,
    Map<String, int>? manualOffsets,
  }) {
    final params = _getAdjustedParams(methodName, useHanafi, manualOffsets);
    final dateComponents = DateComponents(date.year, date.month, date.day);
    return PrayerTimes(coordinates, dateComponents, params);
  }


  /// Format a DateTime to '5:30 AM' style string in the local timezone.
  static String formatTime(DateTime time) {
    // Adhan returns times in UTC by default, convert to local device time
    return DateFormat('h:mm a').format(time.toLocal());
  }

  /// Build prayer time range strings from calculated PrayerTimes.
  /// Returns a map: { 'Fajr': '5:12 AM - 6:33 AM', ... }
  static Map<String, String> getPrayerTimeRanges({
    required Coordinates coordinates,
    String methodName = 'ISNA',
    bool useHanafi = false,
    Map<String, int>? manualOffsets,
  }) {
    final times = calculateTimes(
      coordinates: coordinates,
      methodName: methodName,
      useHanafi: useHanafi,
      manualOffsets: manualOffsets,
    );

    return {
      'Fajr': '${formatTime(times.fajr)} - ${formatTime(times.sunrise)}',
      'Dhuhr': '${formatTime(times.dhuhr)} - ${formatTime(times.asr)}',
      'Asr': '${formatTime(times.asr)} - ${formatTime(times.maghrib)}',
      'Maghrib': '${formatTime(times.maghrib)} - ${formatTime(times.isha)}',
      'Isha': '${formatTime(times.isha)} - Midnight',
    };
  }
}
