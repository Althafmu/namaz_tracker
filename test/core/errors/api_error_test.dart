import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_tracker/core/errors/api_error.dart';

void main() {
  group('ApiError', () {
    group('fromResponse', () {
      test('parses standard {code, detail, field_errors} contract', () {
        final data = {
          'code': 'PRAYER_NOT_FOUND',
          'detail': 'No prayer log exists for this date.',
          'field_errors': {
            'date': ['Invalid date format.'],
          },
        };

        final error = ApiError.fromResponse(data, statusCode: 400);

        expect(error.code, 'PRAYER_NOT_FOUND');
        expect(error.detail, 'No prayer log exists for this date.');
        expect(error.fieldErrors['date'], ['Invalid date format.']);
      });

      test('parses response with only code and detail', () {
        final data = {
          'code': 'UNDO_EXPIRED',
          'detail': 'The undo window has expired.',
        };

        final error = ApiError.fromResponse(data, statusCode: 400);

        expect(error.code, 'UNDO_EXPIRED');
        expect(error.detail, 'The undo window has expired.');
        expect(error.fieldErrors, isEmpty);
      });

      test('handles DRF-style {detail} response', () {
        final data = {'detail': 'Authentication credentials were not provided.'};

        final error = ApiError.fromResponse(data, statusCode: 401);

        expect(error.code, 'UNAUTHORIZED');
        expect(error.detail, 'Authentication credentials were not provided.');
      });

      test('handles DRF-style field error map without code', () {
        final data = {
          'email': ['This field is required.'],
          'password': ['Password too short.'],
        };

        final error = ApiError.fromResponse(data, statusCode: 400);

        expect(error.code, 'VALIDATION_ERROR');
        expect(error.fieldErrors['email'], ['This field is required.']);
        expect(error.fieldErrors['password'], ['Password too short.']);
      });

      test('handles null response body', () {
        final error = ApiError.fromResponse(null, statusCode: 500);

        expect(error.code, 'SERVER_ERROR');
        expect(error.detail, contains('Something went wrong'));
      });

      test('handles empty map response', () {
        final error = ApiError.fromResponse(<String, dynamic>{}, statusCode: 404);

        expect(error.code, 'NOT_FOUND');
        expect(error.detail, contains('not found'));
      });

      test('handles string response body', () {
        final error = ApiError.fromResponse('Internal Server Error', statusCode: 500);

        expect(error.code, 'SERVER_ERROR');
        expect(error.detail, 'Internal Server Error');
      });

      test('handles null statusCode', () {
        final error = ApiError.fromResponse(null);

        expect(error.code, 'UNKNOWN_ERROR');
        expect(error.detail, contains('unexpected error'));
      });

      test('handles field_errors with non-list values', () {
        final data = {
          'code': 'VALIDATION_ERROR',
          'detail': 'Validation failed.',
          'field_errors': {
            'name': 'Required field',
          },
        };

        final error = ApiError.fromResponse(data, statusCode: 400);

        expect(error.fieldErrors['name'], ['Required field']);
      });

      test('maps all known status codes correctly', () {
        expect(ApiError.fromResponse(null, statusCode: 400).code, 'VALIDATION_ERROR');
        expect(ApiError.fromResponse(null, statusCode: 401).code, 'UNAUTHORIZED');
        expect(ApiError.fromResponse(null, statusCode: 403).code, 'FORBIDDEN');
        expect(ApiError.fromResponse(null, statusCode: 404).code, 'NOT_FOUND');
        expect(ApiError.fromResponse(null, statusCode: 409).code, 'CONFLICT');
        expect(ApiError.fromResponse(null, statusCode: 429).code, 'RATE_LIMITED');
        expect(ApiError.fromResponse(null, statusCode: 500).code, 'SERVER_ERROR');
        expect(ApiError.fromResponse(null, statusCode: 502).code, 'UNKNOWN_ERROR');
      });
    });

    group('fieldErrorSummary', () {
      test('returns null when no field errors', () {
        final error = ApiError(code: 'TEST', detail: 'test');
        expect(error.fieldErrorSummary, isNull);
      });

      test('formats single field error', () {
        final error = ApiError(
          code: 'TEST',
          detail: 'test',
          fieldErrors: {'email': ['Invalid email']},
        );
        expect(error.fieldErrorSummary, 'email: Invalid email');
      });

      test('formats multiple field errors', () {
        final error = ApiError(
          code: 'TEST',
          detail: 'test',
          fieldErrors: {
            'email': ['Invalid email'],
            'name': ['Required', 'Too short'],
          },
        );
        expect(error.fieldErrorSummary, 'email: Invalid email; name: Required, Too short');
      });
    });

    group('userMessage', () {
      test('prefers field errors over detail', () {
        final error = ApiError(
          code: 'TEST',
          detail: 'Generic error',
          fieldErrors: {'email': ['Invalid email']},
        );
        expect(error.userMessage, 'email: Invalid email');
      });

      test('falls back to detail when no field errors', () {
        final error = ApiError(code: 'TEST', detail: 'Generic error');
        expect(error.userMessage, 'Generic error');
      });
    });
  });
}
