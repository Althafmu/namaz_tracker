import 'package:equatable/equatable.dart';
import '../../../../../core/services/time_service.dart';
import '../../../domain/entities/prayer_notification_config.dart';

enum IntentLevel {
  foundation,
  strengthening,
  growth;

  String get displayName {
    switch (this) {
      case IntentLevel.foundation:
        return 'Foundation';
      case IntentLevel.strengthening:
        return 'Strengthening';
      case IntentLevel.growth:
        return 'Growth';
    }
  }

  String get subtitle {
    switch (this) {
      case IntentLevel.foundation:
        return 'Start your habit. Full recovery options if you miss.';
      case IntentLevel.strengthening:
        return 'Stay consistent. Priority prayer recovery.';
      case IntentLevel.growth:
        return 'Push yourself. Focus on priority prayers.';
    }
  }

  static IntentLevel fromString(String value) {
    switch (value) {
      case 'strengthening':
        return IntentLevel.strengthening;
      case 'growth':
        return IntentLevel.growth;
      default:
        return IntentLevel.foundation;
    }
  }
}

class MilestoneState extends Equatable {
  final Map<int, bool> shownMilestones;

  const MilestoneState({this.shownMilestones = const {}});

  bool isShown(int milestone) => shownMilestones[milestone] ?? false;

  MilestoneState markShown(int milestone) {
    final updated = Map<int, bool>.from(shownMilestones);
    updated[milestone] = true;
    return MilestoneState(shownMilestones: updated);
  }

  Map<String, dynamic> toJson() => {'shownMilestones': shownMilestones};

  factory MilestoneState.fromJson(Map<String, dynamic> json) {
    final raw = json['shownMilestones'] as Map<String, dynamic>?;
    if (raw == null) return const MilestoneState();
    final converted = <int, bool>{};
    raw.forEach((key, value) => converted[int.parse(key)] = value as bool);
    return MilestoneState(shownMilestones: converted);
  }

  @override
  List<Object?> get props => [shownMilestones];
}

class UpgradePromptState extends Equatable {
  final DateTime? lastShownAt;
  final bool dismissed;

  const UpgradePromptState({this.lastShownAt, this.dismissed = false});

  bool get canShow {
    if (!dismissed) return true;
    if (lastShownAt == null) return true;
    return TimeService.effectiveNow().difference(lastShownAt!).inDays >= 3;
  }

  UpgradePromptState markShown() {
    return UpgradePromptState(
      lastShownAt: TimeService.effectiveNow(),
      dismissed: false,
    );
  }

  UpgradePromptState markDismissed() {
    return UpgradePromptState(lastShownAt: lastShownAt, dismissed: true);
  }

  Map<String, dynamic> toJson() {
    return {
      'lastShownAt': lastShownAt?.toIso8601String(),
      'dismissed': dismissed,
    };
  }

  factory UpgradePromptState.fromJson(Map<String, dynamic> json) {
    return UpgradePromptState(
      lastShownAt: json['lastShownAt'] != null
          ? DateTime.parse(json['lastShownAt'] as String)
          : null,
      dismissed: json['dismissed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [lastShownAt, dismissed];
}

/// Status of the pause-notifications action.
enum PauseActionStatus { idle, loading, success, error }

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

  // Dates marked as excused (yyyy-MM-dd strings) — notifications suppressed for these days
  final Set<String> excusedDays;

  // Phase 3.1: Intent-driven behavior
  final IntentLevel intentLevel;
  final int bestStreak;
  final int lastStreak;
  final MilestoneState milestones;
  final UpgradePromptState upgradePrompt;
  final bool isIntentSet;
  final bool isFallbackIntent;
  final bool isInitialized;

  /// Whether the one-time home welcome banner has been shown on this device.
  final bool hasSeenHomeWelcomeBanner;

  /// Whether the first-run setup dialog (contextual tips on Home) has been completed.
  final bool hasCompletedFirstRunSetup;

  /// Whether notifications are paused for today (backend-synced).
  final bool notificationsPausedToday;

  /// Status of the pause-notifications-for-today action.
  final PauseActionStatus pauseActionStatus;

  /// Growth-only optional Sunna tracking toggle.
  final bool sunnahEnabled;

  /// Whether Qada analytics should be visible in profile/progress surfaces.
  final bool qadaTrackingEnabled;

  /// Whether the notification permission overlay has been shown after login.
  final bool hasSeenLoginNotificationPrompt;

  /// Message to display after a settings action.
  final String? lastSettingsActionMessage;

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
    this.excusedDays = const {},
    this.intentLevel = IntentLevel.foundation,
    this.bestStreak = 0,
    this.lastStreak = 0,
    this.milestones = const MilestoneState(),
    this.upgradePrompt = const UpgradePromptState(),
    this.isIntentSet = false,
    this.isFallbackIntent = false,
    this.isInitialized = false,
    this.hasSeenHomeWelcomeBanner = false,
    this.hasCompletedFirstRunSetup = false,
    this.notificationsPausedToday = false,
    this.pauseActionStatus = PauseActionStatus.idle,
    this.sunnahEnabled = false,
    this.qadaTrackingEnabled = false,
    this.hasSeenLoginNotificationPrompt = false,
    this.lastSettingsActionMessage,
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
    Set<String>? excusedDays,
    IntentLevel? intentLevel,
    int? bestStreak,
    int? lastStreak,
    MilestoneState? milestones,
    UpgradePromptState? upgradePrompt,
    bool? isIntentSet,
    bool? isFallbackIntent,
    bool? isInitialized,
    bool? hasSeenHomeWelcomeBanner,
    bool? hasCompletedFirstRunSetup,
    bool? notificationsPausedToday,
    PauseActionStatus? pauseActionStatus,
    bool? sunnahEnabled,
    bool? qadaTrackingEnabled,
    bool? hasSeenLoginNotificationPrompt,
    String? lastSettingsActionMessage,
    bool clearActionMessage = false,
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
      excusedDays: excusedDays ?? this.excusedDays,
      intentLevel: intentLevel ?? this.intentLevel,
      bestStreak: bestStreak ?? this.bestStreak,
      lastStreak: lastStreak ?? this.lastStreak,
      milestones: milestones ?? this.milestones,
      upgradePrompt: upgradePrompt ?? this.upgradePrompt,
      isIntentSet: isIntentSet ?? this.isIntentSet,
      isFallbackIntent: isFallbackIntent ?? this.isFallbackIntent,
      isInitialized: isInitialized ?? this.isInitialized,
      hasSeenHomeWelcomeBanner:
          hasSeenHomeWelcomeBanner ?? this.hasSeenHomeWelcomeBanner,
      hasCompletedFirstRunSetup:
          hasCompletedFirstRunSetup ?? this.hasCompletedFirstRunSetup,
      notificationsPausedToday:
          notificationsPausedToday ?? this.notificationsPausedToday,
      pauseActionStatus: pauseActionStatus ?? this.pauseActionStatus,
      sunnahEnabled: sunnahEnabled ?? this.sunnahEnabled,
      qadaTrackingEnabled: qadaTrackingEnabled ?? this.qadaTrackingEnabled,
      hasSeenLoginNotificationPrompt:
          hasSeenLoginNotificationPrompt ?? this.hasSeenLoginNotificationPrompt,
      lastSettingsActionMessage: clearActionMessage
          ? null
          : (lastSettingsActionMessage ?? this.lastSettingsActionMessage),
    );
  }

  bool get isExcused {
    final today = TimeService.effectiveNow();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return excusedDays.contains(todayStr);
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
      'excusedDays': excusedDays.toList(),
      'intentLevel': intentLevel.name,
      'bestStreak': bestStreak,
      'lastStreak': lastStreak,
      'milestones': milestones.toJson(),
      'upgradePrompt': upgradePrompt.toJson(),
      'isIntentSet': isIntentSet,
      'isFallbackIntent': isFallbackIntent,
      'isInitialized': isInitialized,
      'hasSeenHomeWelcomeBanner': hasSeenHomeWelcomeBanner,
      'hasCompletedFirstRunSetup': hasCompletedFirstRunSetup,
      'notificationsPausedToday': notificationsPausedToday,
      'sunnahEnabled': sunnahEnabled,
      'qadaTrackingEnabled': qadaTrackingEnabled,
      'hasSeenLoginNotificationPrompt': hasSeenLoginNotificationPrompt,
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
      themeMode:
          json['themeMode'] as String? ??
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
      excusedDays:
          (json['excusedDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      intentLevel: json['intentLevel'] != null
          ? IntentLevel.fromString(json['intentLevel'] as String)
          : IntentLevel.foundation,
      bestStreak: json['bestStreak'] as int? ?? 0,
      lastStreak: json['lastStreak'] as int? ?? 0,
      milestones: json['milestones'] != null
          ? MilestoneState.fromJson(json['milestones'] as Map<String, dynamic>)
          : const MilestoneState(),
      upgradePrompt: json['upgradePrompt'] != null
          ? UpgradePromptState.fromJson(
              json['upgradePrompt'] as Map<String, dynamic>,
            )
          : const UpgradePromptState(),
      isIntentSet: json['isIntentSet'] as bool? ?? false,
      isFallbackIntent: json['isFallbackIntent'] as bool? ?? false,
      isInitialized: true,
      hasSeenHomeWelcomeBanner: json.containsKey('hasSeenHomeWelcomeBanner')
          ? (json['hasSeenHomeWelcomeBanner'] as bool? ?? false)
          : true,
      hasCompletedFirstRunSetup: json.containsKey('hasCompletedFirstRunSetup')
          ? (json['hasCompletedFirstRunSetup'] as bool? ?? false)
          : true,
      notificationsPausedToday:
          json['notificationsPausedToday'] as bool? ?? false,
      sunnahEnabled: json['sunnahEnabled'] as bool? ?? false,
      qadaTrackingEnabled: json.containsKey('qadaTrackingEnabled')
          ? (json['qadaTrackingEnabled'] as bool? ?? false)
          : false,
      hasSeenLoginNotificationPrompt:
          json['hasSeenLoginNotificationPrompt'] as bool? ?? false,
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
    excusedDays,
    intentLevel,
    bestStreak,
    lastStreak,
    milestones,
    upgradePrompt,
    isIntentSet,
    isFallbackIntent,
    isInitialized,
    hasSeenHomeWelcomeBanner,
    hasCompletedFirstRunSetup,
    notificationsPausedToday,
    pauseActionStatus,
    sunnahEnabled,
    qadaTrackingEnabled,
    hasSeenLoginNotificationPrompt,
    lastSettingsActionMessage,
  ];
}
