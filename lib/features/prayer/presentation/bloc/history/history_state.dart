import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/prayer.dart';

/// State for the HistoryBloc — manages historical prayer data and calendar navigation.
class HistoryState extends Equatable {
  /// Historical log: date string ('2026-03-18') -> list of individual prayers
  final Map<String, List<Prayer>> historicalLog;

  /// Current calendar navigation state
  final int calendarYear;
  final int calendarMonth;

  /// Track which months have been fetched from backend (to avoid re-fetching)
  final Set<String> fetchedMonths;

  /// Selected date for viewing/editing past logs
  final String? selectedDateStr;

  HistoryState({
    this.historicalLog = const {},
    int? calendarYear,
    int? calendarMonth,
    this.fetchedMonths = const {},
    this.selectedDateStr,
  })  : calendarYear = calendarYear ?? DateTime.now().year,
        calendarMonth = calendarMonth ?? DateTime.now().month;

  /// Today's date key for comparisons
  static String get todayKey {
    final effectiveNow = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(effectiveNow);
  }

  HistoryState copyWith({
    Map<String, List<Prayer>>? historicalLog,
    int? calendarYear,
    int? calendarMonth,
    Set<String>? fetchedMonths,
    String? selectedDateStr,
    bool clearSelectedDate = false,
  }) {
    return HistoryState(
      historicalLog: historicalLog ?? this.historicalLog,
      calendarYear: calendarYear ?? this.calendarYear,
      calendarMonth: calendarMonth ?? this.calendarMonth,
      fetchedMonths: fetchedMonths ?? this.fetchedMonths,
      selectedDateStr: clearSelectedDate ? null : (selectedDateStr ?? this.selectedDateStr),
    );
  }

  /// Get the last 7 days' completion percentages for the weekly chart.
  /// Excused prayers are excluded from the count (they don't inflate completion %).
  List<double> get weeklyPercentages {
    final effectiveNow = DateTime.now();
    return List.generate(7, (i) {
      final date = effectiveNow.subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final pastPrayers = historicalLog[key] ?? [];
      final validCompleted = pastPrayers.where((p) => p.isCompleted && !p.isExcused).length;
      return validCompleted / 5.0;
    });
  }

  /// Total valid prayers completed in the last 7 days (excused excluded).
  int get weeklyPrayerCount {
    final effectiveNow = DateTime.now();
    int total = 0;
    for (int i = 0; i < 7; i++) {
      final date = effectiveNow.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final pastPrayers = historicalLog[key] ?? [];
      total += pastPrayers.where((p) => p.isCompleted && !p.isExcused).length;
    }
    return total;
  }

  /// Day labels for the last 7 days.
  List<String> get weeklyDayLabels {
    final effectiveNow = DateTime.now();
    return List.generate(7, (i) {
      final date = effectiveNow.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date).substring(0, 1);
    });
  }

  /// JSON serialization for HydratedBloc.
  Map<String, dynamic> toJson() {
    return {
      'historicalLog': historicalLog.map(
        (k, v) => MapEntry(k, v.map((p) => p.toJson()).toList()),
      ),
      'calendarYear': calendarYear,
      'calendarMonth': calendarMonth,
      'fetchedMonths': fetchedMonths.toList(),
      'selectedDateStr': selectedDateStr,
    };
  }

  factory HistoryState.fromJson(Map<String, dynamic> json) {
    return HistoryState(
      historicalLog: _parseHistoricalLog(json['historicalLog']),
      calendarYear: json['calendarYear'] as int?,
      calendarMonth: json['calendarMonth'] as int?,
      fetchedMonths: (json['fetchedMonths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      selectedDateStr: json['selectedDateStr'] as String?,
    );
  }

  static Map<String, List<Prayer>> _parseHistoricalLog(dynamic json) {
    if (json == null || json is! Map) return {};
    final Map<String, List<Prayer>> log = {};
    json.forEach((key, value) {
      if (value is List) {
        log[key as String] = value
            .map((p) => Prayer.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    });
    return log;
  }

  @override
  List<Object?> get props => [
        historicalLog,
        calendarYear,
        calendarMonth,
        fetchedMonths,
        selectedDateStr,
      ];
}