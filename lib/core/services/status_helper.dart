/// Provides deterministic, user-facing labels, tooltips, and descriptions
/// for prayer status values.
///
/// All status text shown in the app should flow through this helper to ensure
/// consistency between home, progress, and profile views.
///
/// Status semantics match the backend classification rules:
/// - `on_time`: Logged within the prayer's valid time window.
/// - `late`: Logged after the prayer window ended but before the next prayer.
/// - `qada`: Make-up prayer logged after the next prayer's time began.
/// - `missed`: Prayer time passed with no log recorded.
/// - `excused`: Day marked as excused (travel, illness, etc.).
/// - `pending`: Prayer time has not yet arrived or log not yet submitted.
class StatusHelper {
  StatusHelper._();

  /// Short user-facing label for each status value.
  static String label(String status) {
    switch (status) {
      case 'on_time':
        return 'On Time';
      case 'late':
        return 'Late';
      case 'qada':
        return 'Qada';
      case 'missed':
        return 'Missed';
      case 'excused':
        return 'Excused';
      case 'pending':
        return 'Pending';
      default:
        return 'Pending';
    }
  }

  /// Tooltip text explaining what this status means.
  /// Used in prayer cards and progress views.
  static String tooltip(String status) {
    switch (status) {
      case 'on_time':
        return 'Completed within the prayer time window';
      case 'late':
        return 'Completed after the ideal window but before the next prayer';
      case 'qada':
        return 'Make-up prayer completed after the next prayer began';
      case 'missed':
        return 'Prayer time passed without being logged';
      case 'excused':
        return 'Day marked as excused — streak is preserved';
      case 'pending':
        return 'Prayer time has not yet arrived';
      default:
        return 'Status could not be determined';
    }
  }

  /// Longer description for boundary cases, used in helper text.
  static String description(String status) {
    switch (status) {
      case 'on_time':
        return 'Great job! You prayed within the designated time.';
      case 'late':
        return 'You prayed after the ideal window ended, but it still counts '
            'toward your streak. The server determines "late" based on when '
            'the next prayer time begins.';
      case 'qada':
        return 'This is a make-up prayer. Qada is recorded when you complete a '
            'prayer after the next prayer\'s time has already started. It counts '
            'toward your streak but is tracked separately.';
      case 'missed':
        return 'This prayer was not logged before the deadline. If a protector '
            'token is available, you may still recover your streak.';
      case 'excused':
        return 'This day is marked as excused. Your streak is frozen and will '
            'resume when you return to regular prayer.';
      case 'pending':
        return 'This prayer\'s time has not yet arrived. It will be available '
            'to log once the adhan time passes.';
      default:
        return 'The status of this prayer could not be determined. '
            'Please refresh to sync with the server.';
    }
  }

  /// Returns the emoji/icon name to use for this status in text contexts.
  static String emoji(String status) {
    switch (status) {
      case 'on_time':
        return '✅';
      case 'late':
        return '⏰';
      case 'qada':
        return '🔄';
      case 'missed':
        return '❌';
      case 'excused':
        return '🛡️';
      case 'pending':
        return '⏳';
      default:
        return '❓';
    }
  }

  /// Whether this status counts toward streak.
  /// Must match the server-side logic exactly.
  static bool countsForStreak(String status) {
    switch (status) {
      case 'on_time':
      case 'late':
      case 'qada':
        return true;
      case 'excused':
        // Excused days preserve streak (freeze) but don't increment
        return false;
      case 'missed':
      case 'pending':
      default:
        return false;
    }
  }

  /// Whether excused status should freeze (not break) the streak.
  static bool freezesStreak(String status) {
    return status == 'excused';
  }

  /// All known status values for validation purposes.
  static const knownStatuses = {
    'on_time',
    'late',
    'qada',
    'missed',
    'excused',
    'pending',
  };

  /// Returns true if the status string is a known backend status.
  static bool isKnown(String status) => knownStatuses.contains(status);
}
