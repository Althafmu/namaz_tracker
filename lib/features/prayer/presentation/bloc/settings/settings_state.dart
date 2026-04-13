import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer_notification_config.dart';

class SettingsState extends Equatable {
  final String calculationMethod;
  final bool useHanafi;

  // Global settings
  final String alarmSound;
  final bool notificationsPermitted;

  // Theme
  final String themeMode;

  // Per-prayer configs
  final Map<String, PrayerNotificationConfig> prayerConfigs;

  // Manual offsets in minutes
  final Map<String, int> manualOffsets;

  // To know if method has been manually overridden
  final bool methodAutoDetected;

  final List<String> missedReasons;
  final int alarmDurationMinutes;

  const SettingsState({
    this.calculationMethod = 'MWL',
    this.useHanafi = false,
    this.alarmSound = 'system',
    this.notificationsPermitted = false,
    this.themeMode = 'system',
    this.prayerConfigs = const {
      'Fajr': PrayerNotificationConfig(),
      'Dhuhr': PrayerNotificationConfig(),
      'Asr': PrayerNotificationConfig(),
      'Maghrib': PrayerNotificationConfig(),
      'Isha': PrayerNotificationConfig(),
    },
    this.manualOffsets = const {
      'Fajr': 0,
      'Sunrise': 0,
      'Dhuhr': 0,
      'Asr': 0,
      'Maghrib': 0,
      'Isha': 0,
    },
    this.methodAutoDetected = false,
    this.missedReasons = const [
      'Forgot',
      'Sleeping',
      'Busy with work',
      'Travelling',
      'Health reasons',
      'Other',
    ],
    this.alarmDurationMinutes = 1,
  });

  SettingsState copyWith({
    String? calculationMethod,
    bool? useHanafi,
    String? alarmSound,
    bool? notificationsPermitted,
    String? themeMode,
    Map<String, PrayerNotificationConfig>? prayerConfigs,
    Map<String, int>? manualOffsets,
    bool? methodAutoDetected,
    List<String>? missedReasons,
    int? alarmDurationMinutes,
  }) {
    return SettingsState(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      useHanafi: useHanafi ?? this.useHanafi,
      alarmSound: alarmSound ?? this.alarmSound,
      notificationsPermitted:
          notificationsPermitted ?? this.notificationsPermitted,
      themeMode: themeMode ?? this.themeMode,
      prayerConfigs: prayerConfigs ?? this.prayerConfigs,
      manualOffsets: manualOffsets ?? this.manualOffsets,
      methodAutoDetected: methodAutoDetected ?? this.methodAutoDetected,
      missedReasons: missedReasons ?? this.missedReasons,
      alarmDurationMinutes: alarmDurationMinutes ?? this.alarmDurationMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calculationMethod': calculationMethod,
      'useHanafi': useHanafi,
      'alarmSound': alarmSound,
      'notificationsPermitted': notificationsPermitted,
      'themeMode': themeMode,
      'prayerConfigs': prayerConfigs.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'manualOffsets': manualOffsets,
      'methodAutoDetected': methodAutoDetected,
      'missedReasons': missedReasons,
      'alarmDurationMinutes': alarmDurationMinutes,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    Map<String, PrayerNotificationConfig> parsedConfigs = {};
    if (json['prayerConfigs'] != null) {
      final configsJson = json['prayerConfigs'] as Map<String, dynamic>;
      configsJson.forEach((key, value) {
        parsedConfigs[key] = PrayerNotificationConfig.fromJson(
          value as Map<String, dynamic>,
        );
      });
      for (var p in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        if (!parsedConfigs.containsKey(p)) {
          parsedConfigs[p] = const PrayerNotificationConfig();
        }
      }
    } else {
      final legacyAdhan = json['adhanAlerts'] as bool? ?? true;
      final legacyReminder = json['reminderAlerts'] as bool? ?? false;
      final legacyReminderMinutes = json['reminderMinutes'] as int? ?? 15;
      final legacyReminderIsBefore = json['reminderIsBefore'] as bool? ?? false;
      final legacyStreakProtection = json['streakProtection'] as bool? ?? false;

      final migratedConfig = PrayerNotificationConfig(
        adhanAlerts: legacyAdhan,
        reminderAlerts: legacyReminder,
        reminderMinutes: legacyReminderMinutes,
        reminderIsBefore: legacyReminderIsBefore,
        streakProtection: legacyStreakProtection,
      );

      parsedConfigs = {
        'Fajr': migratedConfig,
        'Dhuhr': migratedConfig,
        'Asr': migratedConfig,
        'Maghrib': migratedConfig,
        'Isha': migratedConfig,
      };
    }

    Map<String, int> parsedOffsets = {
      'Fajr': 0,
      'Sunrise': 0,
      'Dhuhr': 0,
      'Asr': 0,
      'Maghrib': 0,
      'Isha': 0,
    };
    if (json['manualOffsets'] != null) {
      final offsetsJson = json['manualOffsets'] as Map<String, dynamic>;
      offsetsJson.forEach((key, value) {
        if (value is int) {
          parsedOffsets[key] = value;
        }
      });
    }

    return SettingsState(
      calculationMethod: json['calculationMethod'] as String? ?? 'MWL',
      useHanafi: json['useHanafi'] as bool? ?? false,
      alarmSound: json['alarmSound'] as String? ?? 'system',
      notificationsPermitted: json['notificationsPermitted'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ??
          (json['isDarkMode'] == true ? 'dark' : 'system'),
      prayerConfigs: parsedConfigs,
      manualOffsets: parsedOffsets,
      methodAutoDetected: json['methodAutoDetected'] as bool? ?? false,
      missedReasons:
          (json['missedReasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'Forgot',
            'Sleeping',
            'Busy with work',
            'Travelling',
            'Health reasons',
            'Other',
          ],
      alarmDurationMinutes: json['alarmDurationMinutes'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    calculationMethod,
    useHanafi,
    alarmSound,
    notificationsPermitted,
    themeMode,
    prayerConfigs,
    manualOffsets,
    methodAutoDetected,
    missedReasons,
    alarmDurationMinutes,
  ];
}
