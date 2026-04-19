import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/core/errors/api_error.dart';
import 'package:namaz_tracker/core/errors/api_error_mapper.dart';

void main() {
  group('ApiErrorMapper', () {
    group('toUserMessage', () {
      test('maps known error code to user message', () {
        final error = ApiError(code: 'PRAYER_NOT_FOUND', detail: '');
        expect(
          ApiErrorMapper.toUserMessage(error),
          'No prayer record found for this date.',
        );
      });

      test('maps UNDO_NOT_AVAILABLE code', () {
        final error = ApiError(code: 'UNDO_NOT_AVAILABLE', detail: '');
        expect(
          ApiErrorMapper.toUserMessage(error),
          'No recent prayer log to undo.',
        );
      });

      test('maps RATE_LIMITED code', () {
        final error = ApiError(code: 'RATE_LIMITED', detail: '');
        expect(
          ApiErrorMapper.toUserMessage(error),
          'Too many requests. Please wait a moment.',
        );
      });

      test('prefers field errors over code mapping', () {
        final error = ApiError(
          code: 'VALIDATION_ERROR',
          detail: 'Validation failed',
          fieldErrors: {'email': ['Email is required']},
        );
        expect(
          ApiErrorMapper.toUserMessage(error),
          'email: Email is required',
        );
      });

      test('falls back to server detail for unknown code', () {
        final error = ApiError(
          code: 'TOTALLY_NEW_ERROR_CODE',
          detail: 'Something the server said.',
        );
        expect(
          ApiErrorMapper.toUserMessage(error),
          'Something the server said.',
        );
      });

      test('falls back to generic message when code and detail are empty', () {
        final error = ApiError(code: 'UNKNOWN_NEW_CODE', detail: '');
        expect(
          ApiErrorMapper.toUserMessage(error),
          'An unexpected error occurred. Please try again.',
        );
      });
    });

    group('fromCode', () {
      test('returns mapped message for known code', () {
        expect(
          ApiErrorMapper.fromCode('UNAUTHORIZED'),
          'Session expired. Please log in again.',
        );
      });

      test('returns generic message for unknown code', () {
        expect(
          ApiErrorMapper.fromCode('SOME_FUTURE_CODE'),
          'An unexpected error occurred. Please try again.',
        );
      });
    });

    group('isAuthError', () {
      test('returns true for UNAUTHORIZED', () {
        final error = ApiError(code: 'UNAUTHORIZED', detail: '');
        expect(ApiErrorMapper.isAuthError(error), true);
      });

      test('returns true for TOKEN_EXPIRED', () {
        final error = ApiError(code: 'TOKEN_EXPIRED', detail: '');
        expect(ApiErrorMapper.isAuthError(error), true);
      });

      test('returns true for FORBIDDEN', () {
        final error = ApiError(code: 'FORBIDDEN', detail: '');
        expect(ApiErrorMapper.isAuthError(error), true);
      });

      test('returns false for non-auth error', () {
        final error = ApiError(code: 'VALIDATION_ERROR', detail: '');
        expect(ApiErrorMapper.isAuthError(error), false);
      });
    });
  });
}
