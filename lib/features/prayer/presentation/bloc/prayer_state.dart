import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/entities/streak.dart';

enum SyncStatus { idle, syncing, synced, error }

/// State for the PrayerBloc — fully serializable for HydratedBloc.
class PrayerState extends Equatable {
  final List<Prayer> prayers;
  final Streak streak;
  final bool isLoading;
  final SyncStatus syncStatus;
  final String selectedLocation;
  final String? selectedPrayerForLogger;
  final String calculationMethod;
  final bool useHanafi;

  // Notification settings
  final bool adhanAlerts;
  final bool reminderAlerts;
  final int reminderMinutes;
  final bool reminderIsBefore;
  final bool streakProtection;

  // Weekly history: date string ('2026-03-18') -> completed count (0-5)
  final Map<String, int> weeklyHistory;

  const PrayerState({
    this.prayers = const [],
    this.streak = const Streak(),
    this.isLoading = false,
    this.syncStatus = SyncStatus.idle,
    this.selectedLocation = 'home',
    this.selectedPrayerForLogger,
    this.calculationMethod = 'ISNA',
    this.useHanafi = false,
    this.adhanAlerts = true,
    this.reminderAlerts = true,
    this.reminderMinutes = 15,
    this.reminderIsBefore = true,
    this.streakProtection = false,
    this.weeklyHistory = const {},
  });

  PrayerState copyWith({
    List<Prayer>? prayers,
    Streak? streak,
    bool? isLoading,
    SyncStatus? syncStatus,
    String? selectedLocation,
    String? selectedPrayerForLogger,
    String? calculationMethod,
    bool? useHanafi,
    bool? adhanAlerts,
    bool? reminderAlerts,
    int? reminderMinutes,
    bool? reminderIsBefore,
    bool? streakProtection,
    Map<String, int>? weeklyHistory,
  }) {
    return PrayerState(
      prayers: prayers ?? this.prayers,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      syncStatus: syncStatus ?? this.syncStatus,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedPrayerForLogger:
          selectedPrayerForLogger ?? this.selectedPrayerForLogger,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      useHanafi: useHanafi ?? this.useHanafi,
      adhanAlerts: adhanAlerts ?? this.adhanAlerts,
      reminderAlerts: reminderAlerts ?? this.reminderAlerts,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      reminderIsBefore: reminderIsBefore ?? this.reminderIsBefore,
      streakProtection: streakProtection ?? this.streakProtection,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
    );
  }

  /// Number of completed prayers today.
  int get completedCount => prayers.where((p) => p.isCompleted).length;

  /// Whether all 5 prayers are done.
  bool get isAllComplete => completedCount == 5;

  /// Today's date key for weeklyHistory.
  static String get todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Get the last 7 days' completion percentages for the weekly chart.
  List<double> get weeklyPercentages {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      return (weeklyHistory[key] ?? 0) / 5.0;
    });
  }

  /// Total prayers completed in the last 7 days.
  int get weeklyPrayerCount {
    final now = DateTime.now();
    int total = 0;
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      total += weeklyHistory[key] ?? 0;
    }
    return total;
  }

  /// Day labels for the last 7 days.
  List<String> get weeklyDayLabels {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date).substring(0, 1);
    });
  }

  /// JSON serialization for HydratedBloc.
  Map<String, dynamic> toJson() {
    return {
      'prayers': prayers.map((p) => p.toJson()).toList(),
      'streak': streak.toJson(),
      'selectedLocation': selectedLocation,
      'calculationMethod': calculationMethod,
      'useHanafi': useHanafi,
      'adhanAlerts': adhanAlerts,
      'reminderAlerts': reminderAlerts,
      'reminderMinutes': reminderMinutes,
      'reminderIsBefore': reminderIsBefore,
      'streakProtection': streakProtection,
      'weeklyHistory': weeklyHistory,
    };
  }

  factory PrayerState.fromJson(Map<String, dynamic> json) {
    return PrayerState(
      prayers: (json['prayers'] as List<dynamic>?)
              ?.map((p) => Prayer.fromJson(p as Map<String, dynamic>))
              .toList() ??
          Prayer.defaultPrayers(),
      streak: json['streak'] != null
          ? Streak.fromJson(json['streak'] as Map<String, dynamic>)
          : const Streak(),
      selectedLocation: json['selectedLocation'] as String? ?? 'home',
      calculationMethod: json['calculationMethod'] as String? ?? 'ISNA',
      useHanafi: json['useHanafi'] as bool? ?? false,
      adhanAlerts: json['adhanAlerts'] as bool? ?? true,
      reminderAlerts: json['reminderAlerts'] as bool? ?? true,
      reminderMinutes: json['reminderMinutes'] as int? ?? 15,
      reminderIsBefore: json['reminderIsBefore'] as bool? ?? true,
      streakProtection: json['streakProtection'] as bool? ?? false,
      weeklyHistory: (json['weeklyHistory'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
    );
  }

  @override
  List<Object?> get props => [
        prayers,
        streak,
        isLoading,
        syncStatus,
        selectedLocation,
        selectedPrayerForLogger,
        calculationMethod,
        useHanafi,
        adhanAlerts,
        reminderAlerts,
        reminderMinutes,
        reminderIsBefore,
        streakProtection,
        weeklyHistory,
      ];
}
