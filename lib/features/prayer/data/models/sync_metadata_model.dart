import 'package:equatable/equatable.dart';

/// Sync metadata from the backend.
///
/// Tracks when data was last synced, from which source, and if there were
/// any conflicts during sync.
class SyncMetadata extends Equatable {
  /// ISO 8601 timestamp of the last successful sync.
  final String? lastSyncAt;

  /// Source of the last sync (e.g. "app", "web", "api").
  final String? source;

  /// Whether there was a conflict during the last sync.
  final bool hasConflict;

  /// Description of the conflict, if any.
  final String? conflictDetail;

  const SyncMetadata({
    this.lastSyncAt,
    this.source,
    this.hasConflict = false,
    this.conflictDetail,
  });

  factory SyncMetadata.fromJson(Map<String, dynamic> json) {
    return SyncMetadata(
      lastSyncAt: json['last_sync_at'] as String?,
      source: json['source'] as String?,
      hasConflict: json['has_conflict'] as bool? ?? false,
      conflictDetail: json['conflict_detail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSyncAt': lastSyncAt,
      'source': source,
      'hasConflict': hasConflict,
      'conflictDetail': conflictDetail,
    };
  }

  @override
  List<Object?> get props => [lastSyncAt, source, hasConflict, conflictDetail];
}
