import '../entities/streak.dart';
import '../repositories/prayer_repository.dart';

/// Use case to consume a protector token to save streak after Qada prayer.
///
/// This is part of the Phase 2 Streak Freeze system.
/// A protector token allows users to maintain their streak even when
/// they perform a Qada (makeup) prayer within 24 hours.
class ConsumeProtectorTokenUseCase {
  final PrayerRepository repository;

  ConsumeProtectorTokenUseCase(this.repository);

  /// Consume a protector token for a specific date.
  /// If [date] is null, defaults to yesterday.
  /// Returns the updated streak with tokens_remaining decremented.
  Future<Streak> call({String? date}) {
    return repository.consumeProtectorToken(date: date);
  }
}