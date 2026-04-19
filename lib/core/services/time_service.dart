class TimeService {
  /// Returns the current effective time.
  /// If the actual time is before 3:00 AM, it's considered part of the previous logic day.
  static DateTime effectiveNow() {
    final now = DateTime.now();
    if (now.hour < 3) {
      return now.subtract(const Duration(days: 1));
    }
    return now;
  }

  /// Adjusts any given date to its effective daily value based on the 3:00 AM cutoff.
  static DateTime effectiveDate(DateTime input) {
    if (input.hour < 3) {
      return input.subtract(const Duration(days: 1));
    }
    return input;
  }

  /// Checks if the current physical time is between midnight and the cutoff (e.g., 3:00 AM).
  static bool isLateNight() {
    final now = DateTime.now();
    final effective = effectiveNow();
    return effective.day != now.day ||
        effective.month != now.month ||
        effective.year != now.year;
  }
}
