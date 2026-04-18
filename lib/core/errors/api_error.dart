/// Standardized API error model matching the backend contract.
///
/// Backend responses follow the shape:
/// ```json
/// {
///   "code": "PRAYER_NOT_FOUND",
///   "detail": "No prayer log exists for this date.",
///   "field_errors": { "date": ["Invalid date format."] }
/// }
/// ```
class ApiError {
  /// Machine-readable error code (e.g. "PRAYER_NOT_FOUND", "VALIDATION_ERROR").
  final String code;

  /// Human-readable description from the server.
  final String detail;

  /// Per-field validation errors, if any.
  final Map<String, List<String>> fieldErrors;

  const ApiError({
    required this.code,
    required this.detail,
    this.fieldErrors = const {},
  });

  /// Parse a backend error response body into an [ApiError].
  ///
  /// Handles multiple response shapes:
  /// 1. Standard `{code, detail, field_errors}` contract
  /// 2. DRF-style `{detail: "..."}` responses
  /// 3. DRF-style field error maps `{"field": ["error1", "error2"]}`
  /// 4. Non-map responses (plain strings, etc.)
  factory ApiError.fromResponse(dynamic data, {int? statusCode}) {
    if (data == null) {
      return ApiError(
        code: _codeFromStatusCode(statusCode),
        detail: _defaultDetailForStatusCode(statusCode),
      );
    }

    if (data is Map<String, dynamic>) {
      // Standard contract: {code, detail, field_errors}
      final code = data['code'] as String? ?? _codeFromStatusCode(statusCode);
      final detail = data['detail'] as String? ?? '';
      final rawFieldErrors = data['field_errors'];

      Map<String, List<String>> fieldErrors = {};
      if (rawFieldErrors is Map<String, dynamic>) {
        rawFieldErrors.forEach((key, value) {
          if (value is List) {
            fieldErrors[key] = value.map((e) => e.toString()).toList();
          } else if (value != null) {
            fieldErrors[key] = [value.toString()];
          }
        });
      }

      // If no detail was provided, try to extract from DRF-style field errors
      String resolvedDetail = detail;
      if (resolvedDetail.isEmpty && fieldErrors.isEmpty) {
        // DRF sometimes returns {"field": ["error"]} without code/detail
        final drfErrors = <String, List<String>>{};
        data.forEach((key, value) {
          if (key == 'code' || key == 'detail' || key == 'field_errors') return;
          if (value is List) {
            drfErrors[key] = value.map((e) => e.toString()).toList();
          } else if (value is String) {
            drfErrors[key] = [value];
          }
        });
        if (drfErrors.isNotEmpty) {
          fieldErrors = drfErrors;
          resolvedDetail = drfErrors.values.first.join(' ');
        }
      }

      if (resolvedDetail.isEmpty) {
        resolvedDetail = _defaultDetailForStatusCode(statusCode);
      }

      return ApiError(
        code: code,
        detail: resolvedDetail,
        fieldErrors: fieldErrors,
      );
    }

    // Non-map response (e.g. plain string)
    return ApiError(
      code: _codeFromStatusCode(statusCode),
      detail: data.toString(),
    );
  }

  /// Returns a combined field error message, or null if there are none.
  String? get fieldErrorSummary {
    if (fieldErrors.isEmpty) return null;
    final parts = <String>[];
    fieldErrors.forEach((field, errors) {
      parts.add('$field: ${errors.join(', ')}');
    });
    return parts.join('; ');
  }

  /// Best user-facing message: prefers field errors, then detail.
  String get userMessage {
    final fieldSummary = fieldErrorSummary;
    if (fieldSummary != null && fieldSummary.isNotEmpty) {
      return fieldSummary;
    }
    return detail;
  }

  static String _codeFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'VALIDATION_ERROR';
      case 401:
        return 'UNAUTHORIZED';
      case 403:
        return 'FORBIDDEN';
      case 404:
        return 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      case 429:
        return 'RATE_LIMITED';
      case 500:
        return 'SERVER_ERROR';
      default:
        return 'UNKNOWN_ERROR';
    }
  }

  static String _defaultDetailForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'A conflict occurred. Please refresh and try again.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Something went wrong on our end. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() => 'ApiError(code: $code, detail: $detail, fieldErrors: $fieldErrors)';
}
