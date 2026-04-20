import 'package:equatable/equatable.dart';

import 'sunnah_day_summary.dart';

class SunnahWeekSummary extends Equatable {
  final String weekStart;
  final String weekEnd;
  final int totalCompleted;
  final int totalOpportunities;
  final List<SunnahDaySummary> days;

  const SunnahWeekSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.totalCompleted,
    required this.totalOpportunities,
    required this.days,
  });

  double get completionRatio =>
      totalOpportunities == 0 ? 0 : totalCompleted / totalOpportunities;

  Map<String, dynamic> toJson() => {
    'week_start': weekStart,
    'week_end': weekEnd,
    'total_completed': totalCompleted,
    'total_opportunities': totalOpportunities,
    'days': days.map((d) => d.toJson()).toList(),
  };

  factory SunnahWeekSummary.fromJson(Map<String, dynamic> json) {
    return SunnahWeekSummary(
      weekStart: json['week_start'] as String? ?? '',
      weekEnd: json['week_end'] as String? ?? '',
      totalCompleted: json['total_completed'] as int? ?? 0,
      totalOpportunities: json['total_opportunities'] as int? ?? 0,
      days: (json['days'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SunnahDaySummary.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    weekStart,
    weekEnd,
    totalCompleted,
    totalOpportunities,
    days,
  ];
}
