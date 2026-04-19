import '../repositories/prayer_repository.dart';

/// Get sync metadata from the backend.
class GetSyncMetadataUseCase {
  final PrayerRepository repository;

  GetSyncMetadataUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getSyncMetadata();
  }
}
