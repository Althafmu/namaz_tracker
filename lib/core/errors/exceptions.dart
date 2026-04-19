import 'api_error.dart';

/// Base exception for repository-level errors.
/// Allows BLoCs to distinguish between different failure types.
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;

  const AppException(this.message, {this.originalError});

  @override
  String toString() => message;
}

/// Network is unavailable (offline, timeout, connection refused).
class NetworkException extends AppException {
  const NetworkException(super.message, {super.originalError});
}

/// Server returned an error response (4xx, 5xx).
///
/// Carries an optional [apiError] with the standardized backend error contract
/// (`{code, detail, field_errors}`), enabling structured error handling.
class ServerException extends AppException {
  final int? statusCode;

  /// Parsed structured error from the backend, if available.
  final ApiError? apiError;

  const ServerException(
    super.message, {
    this.statusCode,
    this.apiError,
    super.originalError,
  });

  /// The machine-readable error code, or 'UNKNOWN_ERROR' if not available.
  String get errorCode => apiError?.code ?? 'UNKNOWN_ERROR';

  /// User-facing message from the structured error, falling back to [message].
  String get userMessage => apiError?.userMessage ?? message;
}

/// Request was valid but no data exists (404, empty response).
class NoDataException extends AppException {
  const NoDataException(super.message, {super.originalError});
}