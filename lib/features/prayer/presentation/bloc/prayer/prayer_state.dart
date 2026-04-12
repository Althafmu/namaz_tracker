import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/prayer.dart';
import '../../../domain/entities/streak.dart';

enum SyncStatus { idle, syncing, synced, error }

/// State for the PrayerBloc — fully serializable for HydratedBloc.
class PrayerState extends Equatable {
  final List<Prayer> prayers;
  final Streak streak;
  final bool isLoading;
  final SyncStatus syncStatus;
  final String selectedLocation;
  // Cached GPS coordinates to avoid double-fetching
  final double? cachedLat;
  final double? cachedLng;

  // Historical log: date string ('2026-03-18') -> list of individual prayers
  final Map<String, List<Prayer>> historicalLog;

  // Pre-aggregated reason counts from backend (all-time)
  final Map<String, int> reasonCounts;

  // Calendar navigation state
  final int calendarYear;
  final int calendarMonth;

  // Track which months have been fetched from backend (to avoid re-fetching)  
  final Set<String> fetchedMonths;

  // Selected date for viewing/editing past logs (matches DateFormat('yyyy-MM-dd'))
  final String? selectedDateStr;

  PrayerState({
    this.prayers = const [],
    this.streak = const Streak(),
    this.isLoading = false,
    this.syncStatus = SyncStatus.idle,
    this.selectedLocation = 'home',
    this.cachedLat,
    this.cachedLng,
    this.historicalLog = const {},
    this.reasonCounts = const {},
    int? calendarYear,
    int? calendarMonth,
    this.fetchedMonths = const {},
    this.selectedDateStr,
  })  : calendarYear = calendarYear ?? DateTime.now().year,
        calendarMonth = calendarMonth ?? DateTime.now().month;

  PrayerState copyWith({
    List<Prayer>? prayers,
    Streak? streak,
    bool? isLoading,
    SyncStatus? syncStatus,
    String? selectedLocation,
    double? cachedLat,
    double? cachedLng,
    Map<String, List<Prayer>>? historicalLog,
    Map<String, int>? reasonCounts,
    int? calendarYear,
    int? calendarMonth,
    Set<String>? fetchedMonths,
    String? selectedDateStr,
  }) {
    return PrayerState(
      prayers: prayers ?? this.prayers,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      syncStatus: syncStatus ?? this.syncStatus,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      cachedLat: cachedLat ?? this.cachedLat,
      cachedLng: cachedLng ?? this.cachedLng,
      historicalLog: historicalLog ?? this.historicalLog,
      reasonCounts: reasonCounts ?? this.reasonCounts,
      calendarYear: calendarYear ?? this.calendarYear,
      calendarMonth: calendarMonth ?? this.calendarMonth,
      fetchedMonths: fetchedMonths ?? this.fetchedMonths,
      selectedDateStr: selectedDateStr ?? this.selectedDateStr,
    );
  }

  /// The prayers to display on the UI depending on selectedDateStr
  List<Prayer> get displayPrayers {
    final effectiveSelectedDate = selectedDateStr ?? todayKey;
    if (effectiveSelectedDate == todayKey) {
      return prayers;
    }
    return historicalLog[effectiveSelectedDate] ?? Prayer.defaultPrayers();
  }

  /// Number of completed prayers today.
  int get completedCount => displayPrayers.where((p) => p.isCompleted).length;

  /// Whether all 5 prayers are done.
  bool get isAllComplete => completedCount == 5;

  /// Today's date key for weeklyHistory.
  /// Any time before 4:00 AM is considered part of the previous day.
  static String get todayKey {
    final effectiveNow = DateTime.now().subtract(const Duration(hours: 4));
    return DateFormat('yyyy-MM-dd').format(effectiveNow);
  }

  /// Get the last 7 days' completion percentages for the weekly chart.
  List<double> get weeklyPercentages {
    final effectiveNow = DateTime.now().subtract(const Duration(hours: 4));
    return List.generate(7, (i) {
      final date = effectiveNow.subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final pastPrayers = historicalLog[key] ?? [];
      final completed = pastPrayers.where((p) => p.isCompleted).length;
      return completed / 5.0;
    });
  }

  /// Total prayers completed in the last 7 days.
  int get weeklyPrayerCount {
    final effectiveNow = DateTime.now().subtract(const Duration(hours: 4));
    int total = 0;
    for (int i = 0; i < 7; i++) {
      final date = effectiveNow.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final pastPrayers = historicalLog[key] ?? [];
      total += pastPrayers.where((p) => p.isCompleted).length;
    }
    return total;
  }

  /// Day labels for the last 7 days.
  List<String> get weeklyDayLabels {
    final effectiveNow = DateTime.now().subtract(const Duration(hours: 4));
    return List.generate(7, (i) {
      final date = effectiveNow.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date).substring(0, 1);
    });
  }

  /// JSON serialization for HydratedBloc.
  Map<String, dynamic> toJson() {
    return {
      'prayers': prayers.map((p) => p.toJson()).toList(),
      'streak': streak.toJson(),
      'selectedLocation': selectedLocation,
      'cachedLat': cachedLat,
      'cachedLng': cachedLng,
      'historicalLog': historicalLog.map((k, v) => MapEntry(k, v.map((p) => p.toJson()).toList())),
      'reasonCounts': reasonCounts,
      'calendarYear': calendarYear,
      'calendarMonth': calendarMonth,
      'fetchedMonths': fetchedMonths.toList(),
      'selectedDateStr': selectedDateStr,
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
      cachedLat: json['cachedLat'] as double?,
      cachedLng: json['cachedLng'] as double?,
      historicalLog: _parseHistoricalLog(json['historicalLog'], json['weeklyHistory']),
      reasonCounts: _parseReasonCounts(json['reasonCounts']),
      calendarYear: json['calendarYear'] as int?,
      calendarMonth: json['calendarMonth'] as int?,
      fetchedMonths: (json['fetchedMonths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      selectedDateStr: json['selectedDateStr'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        prayers,
        streak,
        isLoading,
        syncStatus,
        selectedLocation,
        cachedLat,
        cachedLng,
        historicalLog,
        reasonCounts,
        calendarYear,
        calendarMonth,
        fetchedMonths,
        selectedDateStr,
      ];
}

Map<String, List<Prayer>> _parseHistoricalLog(dynamic historicalJson, dynamic legacyWeeklyJson) {
  final Map<String, List<Prayer>> log = {};
  
  if (historicalJson != null && historicalJson is Map) {
    historicalJson.forEach((key, value) {
      if (value is List) {
        log[key as String] = value.map((p) => Prayer.fromJson(p as Map<String, dynamic>)).toList();
      }
    });
  } else if (legacyWeeklyJson != null && legacyWeeklyJson is Map) {
    // Migration: generate dummy completed prayers based on the integer count
    legacyWeeklyJson.forEach((key, value) {
      if (value is int) {
        final List<Prayer> base = Prayer.defaultPrayers();
        final List<Prayer> migrated = [];
        for (int i = 0; i < 5; i++) {
          if (i < value) {
            migrated.add(base[i].copyWith(isCompleted: true, status: 'on_time'));
          } else {
            migrated.add(base[i].copyWith(isCompleted: false, status: 'not_logged'));
          }
        }
        log[key as String] = migrated;
      }
    });
  }
  
  return log;
}

Map<String, int> _parseReasonCounts(dynamic json) {
  if (json == null || json is! Map) return {};
  return Map<String, int>.from(
    json.map((key, value) => MapEntry(key as String, (value as num).toInt())),
  );
}
