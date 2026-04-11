import 'package:equatable/equatable.dart';

class PrayerNotificationConfig extends Equatable {
  final bool adhanAlerts;
  final bool reminderAlerts;
  final int reminderMinutes;
  final bool reminderIsBefore;
  final bool streakProtection;

  const PrayerNotificationConfig({
    this.adhanAlerts = true,
    this.reminderAlerts = false,
    this.reminderMinutes = 15,
    this.reminderIsBefore = false,
    this.streakProtection = false,
  });

  PrayerNotificationConfig copyWith({
    bool? adhanAlerts,
    bool? reminderAlerts,
    int? reminderMinutes,
    bool? reminderIsBefore,
    bool? streakProtection,
  }) {
    return PrayerNotificationConfig(
      adhanAlerts: adhanAlerts ?? this.adhanAlerts,
      reminderAlerts: reminderAlerts ?? this.reminderAlerts,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      reminderIsBefore: reminderIsBefore ?? this.reminderIsBefore,
      streakProtection: streakProtection ?? this.streakProtection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adhanAlerts': adhanAlerts,
      'reminderAlerts': reminderAlerts,
      'reminderMinutes': reminderMinutes,
      'reminderIsBefore': reminderIsBefore,
      'streakProtection': streakProtection,
    };
  }

  factory PrayerNotificationConfig.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationConfig(
      adhanAlerts: json['adhanAlerts'] as bool? ?? true,
      reminderAlerts: json['reminderAlerts'] as bool? ?? false,
      reminderMinutes: json['reminderMinutes'] as int? ?? 15,
      reminderIsBefore: json['reminderIsBefore'] as bool? ?? false,
      streakProtection: json['streakProtection'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        adhanAlerts,
        reminderAlerts,
        reminderMinutes,
        reminderIsBefore,
        streakProtection,
      ];
}
