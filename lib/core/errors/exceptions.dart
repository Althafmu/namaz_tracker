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
class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode, super.originalError});
}

/// Request was valid but no data exists (404, empty response).
class NoDataException extends AppException {
  const NoDataException(super.message, {super.originalError});
}