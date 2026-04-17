import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_token.dart';

/// Service for securely storing authentication tokens
class TokenStorage {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyExpiresAt = 'expires_at';
  static const String _keyTokenType = 'token_type';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  /// Save authentication token
  Future<void> saveToken(AuthToken token) async {
    await _storage.write(key: _keyAccessToken, value: token.accessToken);
    if (token.refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: token.refreshToken);
    }
    await _storage.write(key: _keyExpiresAt, value: token.expiresAt.toIso8601String());
    await _storage.write(key: _keyTokenType, value: token.tokenType);
  }

  /// Load authentication token
  Future<AuthToken?> loadToken() async {
    final accessToken = await _storage.read(key: _keyAccessToken);
    if (accessToken == null) return null;

    final refreshToken = await _storage.read(key: _keyRefreshToken);
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    final tokenType = await _storage.read(key: _keyTokenType);

    if (expiresAtStr == null) return null;

    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtStr),
      tokenType: tokenType ?? 'Bearer',
    );
  }

  /// Get access token only
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Get refresh token only
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await loadToken();
    return token != null && token.isValid;
  }

  /// Clear all tokens
  Future<void> clearToken() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyExpiresAt);
    await _storage.delete(key: _keyTokenType);
  }

  /// Save raw token data (from JSON)
  Future<void> saveFromJson(Map<String, dynamic> json) async {
    final token = AuthToken.fromJson(json);
    await saveToken(token);
  }
}
