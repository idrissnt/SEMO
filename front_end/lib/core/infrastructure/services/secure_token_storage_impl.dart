import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:semo/core/domain/services/secure_token_storage.dart';
import 'package:semo/core/utils/logger.dart';

/// Secure implementation of TokenStorage using FlutterSecureStorage
///
/// This class provides a secure storage mechanism for authentication tokens
/// using platform-specific security features.
class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage;
  final AppLogger _logger = AppLogger();

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'access_token_expiry';

  /// Creates a new SecureTokenStorage instance with enhanced security options
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error reading access token',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error reading refresh token',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);
      if (expiryString != null) {
        return DateTime.parse(expiryString);
      }
      return null;
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error reading token expiry',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      _logger.debug('[SecureTokenStorage] Access token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error saving access token',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to save access token');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      _logger.debug('[SecureTokenStorage] Refresh token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error saving refresh token',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to save refresh token');
    }
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    try {
      await _storage.write(
          key: _tokenExpiryKey, value: expiry.toIso8601String());
      _logger.debug('[SecureTokenStorage] Token expiry saved successfully');
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error saving token expiry',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to save token expiry');
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      _logger.debug('[SecureTokenStorage] Access token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error deleting access token',
          error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
      _logger.debug('[SecureTokenStorage] Refresh token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error deleting refresh token',
          error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteTokenExpiry() async {
    try {
      await _storage.delete(key: _tokenExpiryKey);
      _logger.debug('[SecureTokenStorage] Token expiry deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error deleting token expiry',
          error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> clearAllTokens() async {
    try {
      await Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
        deleteTokenExpiry(),
      ]);
      _logger.debug('[SecureTokenStorage] All tokens cleared successfully');
    } catch (e, stackTrace) {
      _logger.error('[SecureTokenStorage] Error clearing all tokens',
          error: e, stackTrace: stackTrace);
    }
  }
}
