import 'dart:async';
import 'package:dio/dio.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../network/token_provider.dart';

class TokenRefreshCoordinator {
  final AuthRepositoryImpl authRepo;
  final TokenProvider tokenProvider;

  bool _isRefreshing = false;
  final List<Completer<void>> _queue = [];
  static const _refreshTimeout = Duration(seconds: 15);

  TokenRefreshCoordinator({
    required this.authRepo,
    required this.tokenProvider,
  });

  Future<void> acquireAndRefresh() async {
    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final newToken = await authRepo.refreshAccessToken().timeout(_refreshTimeout);
        if (newToken != null) {
          for (final c in _queue) {
            c.complete();
          }
          _queue.clear();
        } else {
          _failAll('Refresh returned null');
          throw Exception('Token refresh failed');
        }
      } catch (e) {
        _failAll(e);
        rethrow;
      } finally {
        _isRefreshing = false;
      }
    } else {
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future.timeout(_refreshTimeout);
    }
  }

  String? get currentToken => tokenProvider.token;

  void _failAll(Object error) {
    for (final c in _queue) {
      c.completeError(error);
    }
    _queue.clear();
  }

  void dispose() {
    _failAll('Coordinator disposed');
    _isRefreshing = false;
  }
}