import 'package:dio/dio.dart';
import 'token_refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  final TokenRefreshCoordinator coordinator;
  final Dio dio;

  AuthInterceptor({
    required this.coordinator,
    required this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = coordinator.currentToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/token/refresh/')) {
      final alreadyRetried = err.requestOptions.extra['alreadyRetried'] == true;
      if (alreadyRetried) {
        return handler.next(err);
      }

      try {
        await coordinator.acquireAndRefresh();
        err.requestOptions.extra['alreadyRetried'] = true;
        err.requestOptions.headers['Authorization'] = 'Bearer ${coordinator.currentToken}';
        final retryResponse = await dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (e) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}