import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/features/prayer/data/models/sync_metadata_model.dart';

void main() {
  group('SyncMetadata', () {
    group('fromJson', () {
      test('parses complete sync metadata', () {
        final json = {
          'last_sync_at': '2026-04-14T10:00:00Z',
          'source': 'app',
          'has_conflict': false,
          'conflict_detail': null,
        };

        final metadata = SyncMetadata.fromJson(json);

        expect(metadata.lastSyncAt, '2026-04-14T10:00:00Z');
        expect(metadata.source, 'app');
        expect(metadata.hasConflict, false);
        expect(metadata.conflictDetail, null);
      });

      test('parses metadata with conflict', () {
        final json = {
          'last_sync_at': '2026-04-14T10:00:00Z',
          'source': 'web',
          'has_conflict': true,
          'conflict_detail': 'Fajr log was modified from another device.',
        };

        final metadata = SyncMetadata.fromJson(json);

        expect(metadata.hasConflict, true);
        expect(metadata.conflictDetail, contains('Fajr'));
      });

      test('handles empty/missing fields', () {
        final json = <String, dynamic>{};

        final metadata = SyncMetadata.fromJson(json);

        expect(metadata.lastSyncAt, null);
        expect(metadata.source, null);
        expect(metadata.hasConflict, false);
        expect(metadata.conflictDetail, null);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        const metadata = SyncMetadata(
          lastSyncAt: '2026-04-14T10:00:00Z',
          source: 'app',
          hasConflict: true,
          conflictDetail: 'Conflict',
        );

        final json = metadata.toJson();

        expect(json['lastSyncAt'], '2026-04-14T10:00:00Z');
        expect(json['source'], 'app');
        expect(json['hasConflict'], true);
        expect(json['conflictDetail'], 'Conflict');
      });
    });

    group('equality', () {
      test('equal metadata have same props', () {
        const m1 = SyncMetadata(lastSyncAt: 'A', source: 'app');
        const m2 = SyncMetadata(lastSyncAt: 'A', source: 'app');

        expect(m1, equals(m2));
      });

      test('different metadata are not equal', () {
        const m1 = SyncMetadata(lastSyncAt: 'A', source: 'app');
        const m2 = SyncMetadata(lastSyncAt: 'B', source: 'web');

        expect(m1, isNot(equals(m2)));
      });
    });
  });
}
