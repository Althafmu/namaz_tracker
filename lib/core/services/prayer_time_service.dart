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
  static Future<Coordinates?> getCurrentLocation() async {
    // Fallback coordinates for India (New Delhi)
    final fallbackCoordinates = Coordinates(28.6139, 77.2090);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return fallbackCoordinates;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return fallbackCoordinates;
    }
    if (permission == LocationPermission.deniedForever) return fallbackCoordinates;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return Coordinates(position.latitude, position.longitude);
    } catch (e) {
      return fallbackCoordinates;
    }
  }

  /// Calculate today's prayer times.
  ///
  /// [coordinates] — user's lat/lng
  /// [methodName] — one of the keys in [calculationMethods] (default: 'ISNA')
  /// [useHanafi] — if true, uses Hanafi madhab for Asr (default: false = Shafi)
  static PrayerTimes calculateTimes({
    required Coordinates coordinates,
    String methodName = 'ISNA',
    bool useHanafi = false,
  }) {
    final method = calculationMethods[methodName] ?? CalculationMethod.north_america;
    final params = method.getParameters();
    params.madhab = useHanafi ? Madhab.hanafi : Madhab.shafi;

    return PrayerTimes.today(coordinates, params);
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
  }) {
    final times = calculateTimes(
      coordinates: coordinates,
      methodName: methodName,
      useHanafi: useHanafi,
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
