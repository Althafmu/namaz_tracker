import 'api_error.dart';

/// Maps [ApiError] codes to user-facing messages.
///
/// Provides a single source of truth for all error messages shown to users.
/// Unknown codes fall back to the server-provided detail or a generic message.
class ApiErrorMapper {
  ApiErrorMapper._();

  /// Standard error code → user-facing message mappings.
  static const _codeMessages = <String, String>{
    // Auth
    'UNAUTHORIZED': 'Session expired. Please log in again.',
    'FORBIDDEN': 'You do not have permission to perform this action.',
    'INVALID_CREDENTIALS': 'Invalid email or password. Please try again.',
    'ACCOUNT_DISABLED': 'Your account has been disabled. Contact support.',
    'TOKEN_EXPIRED': 'Your session has expired. Please log in again.',

    // Validation
    'VALIDATION_ERROR': 'Please check your input and try again.',

    // Prayer
    'PRAYER_NOT_FOUND': 'No prayer record found for this date.',
    'PRAYER_ALREADY_LOGGED': 'This prayer has already been logged.',
    'PRAYER_LOG_CONFLICT': 'A newer version of this log exists. Please refresh.',
    'UNDO_NOT_AVAILABLE': 'No recent prayer log to undo.',
    'UNDO_EXPIRED': 'The undo window has expired.',

    // Streak
    'NO_TOKENS_AVAILABLE': 'No streak protector tokens available.',
    'TOKEN_COOLDOWN': 'Please wait before using another protector token.',
    'WEEKLY_LIMIT_REACHED': 'Weekly protector token limit reached.',

    // Sync
    'SYNC_CONFLICT': 'A sync conflict occurred. Refreshing data.',
    'STALE_DATA': 'Your data is outdated. Refreshing.',

    // Settings / Notifications
    'SETTINGS_SYNC_FAILED': 'Failed to sync settings. Your changes are saved locally.',
    'NOTIFICATION_PAUSE_FAILED': 'Could not pause notifications. Please try again.',

    // Rate limiting
    'RATE_LIMITED': 'Too many requests. Please wait a moment.',

    // Server
    'SERVER_ERROR': 'Something went wrong on our end. Please try again later.',
    'SERVICE_UNAVAILABLE': 'Service is temporarily unavailable. Please try again.',

    // Generic
    'NOT_FOUND': 'The requested resource was not found.',
    'CONFLICT': 'A conflict occurred. Please refresh and try again.',
  };

  /// Returns a user-facing message for the given [ApiError].
  ///
  /// Priority:
  /// 1. Field errors (most specific)
  /// 2. Known code mapping
  /// 3. Server-provided detail
  /// 4. Generic fallback
  static String toUserMessage(ApiError error) {
    // Field errors are the most specific
    final fieldSummary = error.fieldErrorSummary;
    if (fieldSummary != null && fieldSummary.isNotEmpty) {
      return fieldSummary;
    }

    // Known code mapping
    final mapped = _codeMessages[error.code];
    if (mapped != null) return mapped;

    // Server-provided detail
    if (error.detail.isNotEmpty) return error.detail;

    // Absolute fallback
    return 'An unexpected error occurred. Please try again.';
  }

  /// Returns a user-facing message from a raw API error code string.
  /// Used when only the code is available (e.g., from cached errors).
  static String fromCode(String code) {
    return _codeMessages[code] ?? 'An unexpected error occurred. Please try again.';
  }

  /// Checks whether the error code indicates the user should re-authenticate.
  static bool isAuthError(ApiError error) {
    return error.code == 'UNAUTHORIZED' ||
        error.code == 'TOKEN_EXPIRED' ||
        error.code == 'FORBIDDEN';
  }
}
