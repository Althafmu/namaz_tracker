import 'package:equatable/equatable.dart';

class SunnahDaySummary extends Equatable {
  final String date;
  final int completedCount;
  final int totalOpportunities;
  final Set<String> completedPrayerTypes;

  const SunnahDaySummary({
    required this.date,
    required this.completedCount,
    required this.totalOpportunities,
    required this.completedPrayerTypes,
  });

  double get completionRatio =>
      totalOpportunities == 0 ? 0 : completedCount / totalOpportunities;

  bool isCompleted(String prayerType) =>
      completedPrayerTypes.contains(prayerType);

  SunnahDaySummary copyWith({
    String? date,
    int? completedCount,
    int? totalOpportunities,
    Set<String>? completedPrayerTypes,
  }) {
    return SunnahDaySummary(
      date: date ?? this.date,
      completedCount: completedCount ?? this.completedCount,
      totalOpportunities: totalOpportunities ?? this.totalOpportunities,
      completedPrayerTypes: completedPrayerTypes ?? this.completedPrayerTypes,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'completed_count': completedCount,
    'total_opportunities': totalOpportunities,
    'prayer_types_completed': completedPrayerTypes.toList(),
  };

  factory SunnahDaySummary.fromJson(Map<String, dynamic> json) {
    return SunnahDaySummary(
      date: json['date'] as String? ?? '',
      completedCount: json['completed_count'] as int? ?? 0,
      totalOpportunities: json['total_opportunities'] as int? ?? 0,
      completedPrayerTypes:
          (json['prayer_types_completed'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toSet(),
    );
  }

  @override
  List<Object?> get props => [
    date,
    completedCount,
    totalOpportunities,
    completedPrayerTypes,
  ];
}
