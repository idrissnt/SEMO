// ignore_for_file: avoid_print

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/logger.dart';

/// Custom exception for authentication-related errors
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Service responsible for managing authentication tokens and state
class AuthService {
  /// Secure storage for persistent token management
  final FlutterSecureStorage storage;

  /// Logger for tracking authentication-related events
  final AppLogger _logger;

  /// Keys for secure token storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Constructor with dependency injection
  const AuthService({
    required this.storage,
    required AppLogger logger,
  }) : _logger = logger;

  /// Retrieves the access token from secure storage
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: _accessTokenKey);
    } catch (e) {
      _logger.error('Error retrieving access token', error: e);
      return null;
    }
  }

  /// Saves the access token to secure storage
  Future<void> saveAccessToken(String token) async {
    try {
      await storage.write(key: _accessTokenKey, value: token);
      _logger.debug('Access token saved successfully');
    } catch (e) {
      _logger.error('Error saving access token', error: e);
      throw const AuthenticationException('Failed to save access token');
    }
  }

  /// Retrieves the refresh token from secure storage
  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: _refreshTokenKey);
    } catch (e) {
      _logger.error('Error retrieving refresh token', error: e);
      return null;
    }
  }

  /// Saves the refresh token to secure storage
  Future<void> saveRefreshToken(String token) async {
    try {
      await storage.write(key: _refreshTokenKey, value: token);
      _logger.debug('Refresh token saved successfully');
    } catch (e) {
      _logger.error('Error saving refresh token', error: e);
      throw const AuthenticationException('Failed to save refresh token');
    }
  }

  /// Checks if the user is authenticated based on token presence
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();

      // Validate token presence and non-emptiness
      final hasValidTokens = _validateTokens(accessToken, refreshToken);

      _logger.debug('Authentication check: $hasValidTokens');
      return hasValidTokens;
    } catch (e) {
      _logger.error('Authentication check failed', error: e);
      return false;
    }
  }

  /// Validates token presence and content
  bool _validateTokens(String? accessToken, String? refreshToken) {
    return accessToken != null &&
        refreshToken != null &&
        accessToken.isNotEmpty &&
        refreshToken.isNotEmpty;
  }

  /// Clears all authentication tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        storage.delete(key: _accessTokenKey),
        storage.delete(key: _refreshTokenKey),
      ]);
      _logger.debug('All tokens cleared successfully');
    } catch (e) {
      _logger.error('Error clearing tokens', error: e);
      throw const AuthenticationException(
          'Failed to clear authentication tokens');
    }
  }
}
