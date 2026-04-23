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
    super.prayedJumah,
  });

  /// Validates and normalizes a prayer status string from the backend.
  ///
  /// Known values: on_time, late, qada, missed, excused, pending.
  /// Unknown values fall back to 'pending' to prevent rendering issues.
  static String _normalizeStatus(dynamic rawStatus) {
    if (rawStatus == null) return 'pending';
    final status = rawStatus.toString();
    const knownStatuses = {
      'on_time',
      'late',
      'qada',
      'missed',
      'excused',
      'pending',
    };
    return knownStatuses.contains(status) ? status : 'pending';
  }

  /// Map Django DailyPrayerLog response into a list of PrayerModels.
  /// Parses all per-prayer fields: completed, inJamaat, status, reason, recovery.
  ///
  /// Null/missing-field safeguards:
  /// - All boolean fields default to `false`
  /// - Status fields are normalized via [_normalizeStatus]
  /// - Location defaults to `'home'`
  /// - Recovery data is only parsed if present and valid
  static List<PrayerModel> fromApiResponse(Map<String, dynamic> json) {
    final defaults = Prayer.defaultPrayers();
    final prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final displayNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    final dateStr = json['date'] as String?;
    final isFriday = dateStr != null && DateTime.tryParse(dateStr)?.weekday == DateTime.friday;
    final prayedJumah = json['prayed_jumah'] as bool? ?? false;
    final dhuhrCompleted = json['dhuhr'] as bool? ?? false;

    // Determine the name of the noon prayer
    if (isFriday) {
      if (!dhuhrCompleted || prayedJumah) {
        displayNames[1] = 'Jum\'ah';
      }
    }

    // Extract recovery data from API response
    final recoveryMap = json['recovery'] as Map<String, dynamic>?;

    return List.generate(5, (i) {
      final key = prayerNames[i];
      final recoveryData = recoveryMap?[key];
      final recoveryState = (recoveryData is Map<String, dynamic>)
          ? RecoveryState.fromJson(recoveryData)
          : null;

      // Safely cast location — could be null or unexpected type
      final rawLocation = json['location'];
      final location = (rawLocation is String && rawLocation.isNotEmpty)
          ? rawLocation
          : 'home';

      return PrayerModel(
        name: displayNames[i],
        timeRange: defaults[i].timeRange,
        isCompleted: json[key] as bool? ?? false,
        inJamaat: json['${key}_in_jamaat'] as bool? ?? false,
        location: location,
        status: _normalizeStatus(json['${key}_status']),
        reason: json['${key}_reason'] as String?,
        recoveryState: recoveryState,
        prayedJumah: json['prayed_jumah'] as bool? ?? false,
      );
    });
  }
}
