import 'package:equatable/equatable.dart';

/// Represents a single prayer entry for a day.
class Prayer extends Equatable {
  final String name;
  final String timeRange;
  final bool isCompleted;
  final bool inJamaat;
  final String location;
  final String status;
  final String? reason;
  final String? baseTime;
  final int? offset;

  const Prayer({
    required this.name,
    required this.timeRange,
    this.isCompleted = false,
    this.inJamaat = false,
    this.location = 'home',
    this.status = 'on_time',
    this.reason,
    this.baseTime,
    this.offset,
  });

  Prayer copyWith({
    String? name,
    String? timeRange,
    bool? isCompleted,
    bool? inJamaat,
    String? location,
    String? status,
    String? reason,
    String? baseTime,
    int? offset,
  }) {
    return Prayer(
      name: name ?? this.name,
      timeRange: timeRange ?? this.timeRange,
      isCompleted: isCompleted ?? this.isCompleted,
      inJamaat: inJamaat ?? this.inJamaat,
      location: location ?? this.location,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      baseTime: baseTime ?? this.baseTime,
      offset: offset ?? this.offset,
    );
  }

  /// Default prayer list for a day with placeholder times.
  static List<Prayer> defaultPrayers() {
    return const [
      Prayer(name: 'Fajr', timeRange: '5:30 AM - Sunrise'),
      Prayer(name: 'Dhuhr', timeRange: '1:15 PM - 4:45 PM'),
      Prayer(name: 'Asr', timeRange: '4:45 PM - Sunset'),
      Prayer(name: 'Maghrib', timeRange: '7:20 PM - 8:45 PM'),
      Prayer(name: 'Isha', timeRange: '8:45 PM - Midnight'),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timeRange': timeRange,
      'isCompleted': isCompleted,
      'inJamaat': inJamaat,
      'location': location,
      'status': status,
      'reason': reason,
      'baseTime': baseTime,
      'offset': offset,
    };
  }

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      name: json['name'] as String,
      timeRange: json['timeRange'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      inJamaat: json['inJamaat'] as bool? ?? false,
      location: json['location'] as String? ?? 'home',
      status: json['status'] as String? ?? 'on_time',
      reason: json['reason'] as String?,
      baseTime: json['baseTime'] as String?,
      offset: json['offset'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    name,
    timeRange,
    isCompleted,
    inJamaat,
    location,
    status,
    reason,
    baseTime,
    offset,
  ];
}
