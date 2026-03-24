import '../../domain/entities/prayer.dart';

/// Data model extending the Prayer entity with server-side JSON mapping.
class PrayerModel extends Prayer {
  const PrayerModel({
    required super.name,
    required super.timeRange,
    super.isCompleted,
    super.inJamaat,
    super.location,
  });

  /// Map Django DailyPrayerLog response into a list of PrayerModels.
  static List<PrayerModel> fromApiResponse(Map<String, dynamic> json) {
    final defaults = Prayer.defaultPrayers();
    return [
      PrayerModel(
        name: 'Fajr',
        timeRange: defaults[0].timeRange,
        isCompleted: json['fajr'] as bool? ?? false,
        inJamaat: json['fajr_in_jamaat'] as bool? ?? false,
        location: json['location'] as String? ?? 'home',
      ),
      PrayerModel(
        name: 'Dhuhr',
        timeRange: defaults[1].timeRange,
        isCompleted: json['dhuhr'] as bool? ?? false,
        inJamaat: json['dhuhr_in_jamaat'] as bool? ?? false,
        location: json['location'] as String? ?? 'home',
      ),
      PrayerModel(
        name: 'Asr',
        timeRange: defaults[2].timeRange,
        isCompleted: json['asr'] as bool? ?? false,
        inJamaat: json['asr_in_jamaat'] as bool? ?? false,
        location: json['location'] as String? ?? 'home',
      ),
      PrayerModel(
        name: 'Maghrib',
        timeRange: defaults[3].timeRange,
        isCompleted: json['maghrib'] as bool? ?? false,
        inJamaat: json['maghrib_in_jamaat'] as bool? ?? false,
        location: json['location'] as String? ?? 'home',
      ),
      PrayerModel(
        name: 'Isha',
        timeRange: defaults[4].timeRange,
        isCompleted: json['isha'] as bool? ?? false,
        inJamaat: json['isha_in_jamaat'] as bool? ?? false,
        location: json['location'] as String? ?? 'home',
      ),
    ];
  }
}
