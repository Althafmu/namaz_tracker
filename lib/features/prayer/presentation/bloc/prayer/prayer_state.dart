import 'package:equatable/equatable.dart';
import '../../../domain/entities/prayer.dart';

enum SyncStatus { idle, syncing, synced, error }

/// State for the PrayerBloc — focused on today's prayers.
/// Historical data is managed by HistoryBloc.
/// Statistics are managed by StatsBloc.
/// Streak is managed by StreakBloc.
class PrayerState extends Equatable {
  /// Today's prayers
  final List<Prayer> prayers;

  /// Loading state for initial data fetch
  final bool isLoading;

  /// Sync status for offline/online state
  final SyncStatus syncStatus;

  /// User's selected location for prayer logging
  final String selectedLocation;

  /// Cached GPS coordinates to avoid double-fetching
  final double? cachedLat;
  final double? cachedLng;

  const PrayerState({
    this.prayers = const [],
    this.isLoading = false,
    this.syncStatus = SyncStatus.idle,
    this.selectedLocation = 'home',
    this.cachedLat,
    this.cachedLng,
  });

  PrayerState copyWith({
    List<Prayer>? prayers,
    bool? isLoading,
    SyncStatus? syncStatus,
    String? selectedLocation,
    double? cachedLat,
    double? cachedLng,
  }) {
    return PrayerState(
      prayers: prayers ?? this.prayers,
      isLoading: isLoading ?? this.isLoading,
      syncStatus: syncStatus ?? this.syncStatus,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      cachedLat: cachedLat ?? this.cachedLat,
      cachedLng: cachedLng ?? this.cachedLng,
    );
  }

  /// Number of completed prayers today.
  int get completedCount => prayers.where((p) => p.isCompleted).length;

  /// Whether all 5 prayers are done.
  bool get isAllComplete => completedCount == 5;

  /// JSON serialization for HydratedBloc.
  Map<String, dynamic> toJson() {
    return {
      'prayers': prayers.map((p) => p.toJson()).toList(),
      'selectedLocation': selectedLocation,
      'cachedLat': cachedLat,
      'cachedLng': cachedLng,
    };
  }

  factory PrayerState.fromJson(Map<String, dynamic> json) {
    return PrayerState(
      prayers: (json['prayers'] as List<dynamic>?)
              ?.map((p) => Prayer.fromJson(p as Map<String, dynamic>))
              .toList() ??
          Prayer.defaultPrayers(),
      selectedLocation: json['selectedLocation'] as String? ?? 'home',
      cachedLat: json['cachedLat'] as double?,
      cachedLng: json['cachedLng'] as double?,
    );
  }

  @override
  List<Object?> get props => [
        prayers,
        isLoading,
        syncStatus,
        selectedLocation,
        cachedLat,
        cachedLng,
      ];
}