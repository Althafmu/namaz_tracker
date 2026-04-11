import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides JWT access & refresh tokens backed by flutter_secure_storage.
///
/// Tokens are loaded once at startup via [loadTokens].
/// The only write path is [updateTokens] (login) and [clearAll] (logout).
class TokenProvider {
  static const _accessKey = 'jwt_access_token';
  static const _refreshKey = 'jwt_refresh_token';

  final FlutterSecureStorage _secureStorage;

  String? _token;
  String? _refreshToken;

  TokenProvider({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Current access token (read-only).
  String? get token => _token;

  /// Current refresh token (read-only).
  String? get refreshToken => _refreshToken;

  /// Load tokens from secure storage into memory. Call once at app startup.
  Future<void> loadTokens() async {
    try {
      _token = await _secureStorage.read(key: _accessKey);
      _refreshToken = await _secureStorage.read(key: _refreshKey);
    } catch (e) {
      debugPrint('[TokenProvider] Keystore error loading tokens: $e. Wiping secure storage.');
      try {
        await _secureStorage.deleteAll();
      } catch (_) {}
      _token = null;
      _refreshToken = null;
    }
  }

  /// Single write path: persist both tokens atomically.
  /// Pass null for [refresh] if the server did not return a refresh token.
  Future<void> updateTokens({
    required String access,
    String? refresh,
  }) async {
    _token = access;
    await _secureStorage.write(key: _accessKey, value: access);
    if (refresh != null) {
      _refreshToken = refresh;
      await _secureStorage.write(key: _refreshKey, value: refresh);
    }
  }

  /// Update only the access token (e.g. after a refresh).
  Future<void> updateAccessToken(String access) async {
    _token = access;
    await _secureStorage.write(key: _accessKey, value: access);
  }

  /// Clear all tokens (logout).
  Future<void> clearAll() async {
    _token = null;
    _refreshToken = null;
    await _secureStorage.delete(key: _accessKey);
    await _secureStorage.delete(key: _refreshKey);
  }
}
