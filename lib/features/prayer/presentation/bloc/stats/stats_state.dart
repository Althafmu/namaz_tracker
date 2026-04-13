import 'package:equatable/equatable.dart';

/// State for the StatsBloc — manages aggregated prayer statistics.
class StatsState extends Equatable {
  /// Pre-aggregated reason counts from backend (all-time)
  final Map<String, int> reasonCounts;

  const StatsState({
    this.reasonCounts = const {},
  });

  StatsState copyWith({
    Map<String, int>? reasonCounts,
  }) {
    return StatsState(
      reasonCounts: reasonCounts ?? this.reasonCounts,
    );
  }

  /// JSON serialization for HydratedBloc.
  Map<String, dynamic> toJson() {
    return {
      'reasonCounts': reasonCounts,
    };
  }

  factory StatsState.fromJson(Map<String, dynamic> json) {
    return StatsState(
      reasonCounts: _parseReasonCounts(json['reasonCounts']),
    );
  }

  static Map<String, int> _parseReasonCounts(dynamic json) {
    if (json == null || json is! Map) return {};
    return Map<String, int>.from(
      json.map((key, value) => MapEntry(key as String, (value as num).toInt())),
    );
  }

  @override
  List<Object?> get props => [reasonCounts];
}