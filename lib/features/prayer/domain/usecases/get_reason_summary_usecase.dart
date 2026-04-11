import '../repositories/prayer_repository.dart';

/// Use case to get pre-aggregated reason counts (all-time).
/// Returns reason string -> count.
class GetReasonSummaryUseCase {
  final PrayerRepository repository;

  GetReasonSummaryUseCase(this.repository);

  Future<Map<String, int>> call() {
    return repository.getReasonSummary();
  }
}
