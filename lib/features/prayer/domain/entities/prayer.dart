import 'package:equatable/equatable.dart';

/// Recovery state for temporary streak protection UX (Sprint 1).
/// Shows when a missed prayer can still be recovered via Qada within 24h.
class RecoveryState extends Equatable {
  final bool isProtected;
  final DateTime? expiresAt;
  final bool requiresQada;
  final bool isExpired;

  const RecoveryState({
    required this.isProtected,
    this.expiresAt,
    required this.requiresQada,
    this.isExpired = false,
  });

  factory RecoveryState.fromJson(Map<String, dynamic> json) {
    return RecoveryState(
      isProtected: json['is_protected'] as bool? ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      requiresQada: json['requires_qada'] as bool? ?? false,
      isExpired: json['is_expired'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [isProtected, expiresAt, requiresQada, isExpired];
}

/// Represents a single prayer entry for a day.
/// Phase 2: Uses PrayerStatus enum for status, adds isQada and isExcused helpers.
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
  final RecoveryState? recoveryState;

  const Prayer({
    required this.name,
    required this.timeRange,
    this.isCompleted = false,
    this.inJamaat = false,
    this.location = 'home',
    this.status = 'pending',
    this.reason,
    this.baseTime,
    this.offset,
    this.recoveryState,
  });

  // Phase 2: Helper getters for status
  bool get isQada => status == 'qada';
  bool get isExcused => status == 'excused';
  bool get isOnTime => status == 'on_time';
  bool get isLate => status == 'late';
  bool get isMissed => status == 'missed';
  bool get isPending => status == 'pending';

  /// Returns true if this prayer counts towards streak (completed with valid status).
  /// Excused days preserve streak continuity (freeze) but don't increment it.
  bool get isValidForStreak => isCompleted && (isOnTime || isLate || isQada || isExcused);

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
    RecoveryState? recoveryState,
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
      recoveryState: recoveryState ?? this.recoveryState,
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
      'recoveryState': recoveryState != null
          ? {
              'is_protected': recoveryState!.isProtected,
              'expires_at': recoveryState!.expiresAt?.toIso8601String(),
              'requires_qada': recoveryState!.requiresQada,
            }
          : null,
    };
  }

  factory Prayer.fromJson(Map<String, dynamic> json) {
    return Prayer(
      name: json['name'] as String,
      timeRange: json['timeRange'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      inJamaat: json['inJamaat'] as bool? ?? false,
      location: json['location'] as String? ?? 'home',
      status: json['status'] as String? ?? 'pending',
      reason: json['reason'] as String?,
      baseTime: json['baseTime'] as String?,
      offset: json['offset'] as int?,
      recoveryState: json['recoveryState'] != null
          ? RecoveryState.fromJson(json['recoveryState'] as Map<String, dynamic>)
          : null,
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
        recoveryState,
      ];
}
