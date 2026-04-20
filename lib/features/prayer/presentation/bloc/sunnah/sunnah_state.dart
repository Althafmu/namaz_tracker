import 'package:equatable/equatable.dart';

import '../../../domain/entities/sunnah_day_summary.dart';
import '../../../domain/entities/sunnah_week_summary.dart';

class SunnahState extends Equatable {
  /// Cached daily summaries keyed by date string (yyyy-MM-dd).
  final Map<String, SunnahDaySummary> dailyCache;

  /// Cached weekly summary (most recently loaded week).
  final SunnahWeekSummary? weekSummary;

  /// Whether a remote sync is in progress.
  final bool isSyncing;

  const SunnahState({
    this.dailyCache = const {},
    this.weekSummary,
    this.isSyncing = false,
  });

  SunnahState copyWith({
    Map<String, SunnahDaySummary>? dailyCache,
    SunnahWeekSummary? weekSummary,
    bool clearWeekSummary = false,
    bool? isSyncing,
  }) {
    return SunnahState(
      dailyCache: dailyCache ?? this.dailyCache,
      weekSummary: clearWeekSummary ? null : (weekSummary ?? this.weekSummary),
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyCache': dailyCache.map((key, value) => MapEntry(key, value.toJson())),
    'weekSummary': weekSummary?.toJson(),
  };

  factory SunnahState.fromJson(Map<String, dynamic> json) {
    final cacheJson = json['dailyCache'] as Map<String, dynamic>? ?? {};
    final parsedCache = cacheJson.map(
      (key, value) => MapEntry(
        key,
        SunnahDaySummary.fromJson(value as Map<String, dynamic>),
      ),
    );

    return SunnahState(
      dailyCache: parsedCache,
      weekSummary: json['weekSummary'] != null
          ? SunnahWeekSummary.fromJson(
              json['weekSummary'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [dailyCache, weekSummary, isSyncing];
}
