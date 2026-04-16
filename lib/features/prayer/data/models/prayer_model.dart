import '../../domain/entities/prayer.dart';

/// Data model extending the Prayer entity with server-side JSON mapping.
class PrayerModel extends Prayer {
  const PrayerModel({
    required super.name,
    required super.timeRange,
    super.isCompleted,
    super.inJamaat,
    super.location,
    super.status,
    super.reason,
    super.recoveryState,
  });

  /// Map Django DailyPrayerLog response into a list of PrayerModels.
  /// Parses all per-prayer fields: completed, inJamaat, status, reason, recovery.
  static List<PrayerModel> fromApiResponse(Map<String, dynamic> json) {
    final defaults = Prayer.defaultPrayers();
    final prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final displayNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    // Extract recovery data from API response
    final recoveryMap = json['recovery'] as Map<String, dynamic>?;

    return List.generate(5, (i) {
      final key = prayerNames[i];
      final recoveryData = recoveryMap?[key] as Map<String, dynamic>?;

      return PrayerModel(
        name: displayNames[i],
        timeRange: defaults[i].timeRange,
        isCompleted: json[key] as bool? ?? false,
        inJamaat: json['${key}_in_jamaat'] as bool? ?? false,
        location: json['location'] as String? ?? 'home',
        status: json['${key}_status'] as String? ?? 'pending',
        reason: json['${key}_reason'] as String?,
        recoveryState: recoveryData != null
            ? RecoveryState.fromJson(recoveryData)
            : null,
      );
    });
  }
}
