// No need for dart:convert with Dio
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/domain/services/token_service.dart';

/// Handles all token-related operations including storage, retrieval, and validation
class TokenServiceImpl implements TokenService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final AppLogger _logger = AppLogger();

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  TokenServiceImpl({
    required Dio dio,
    required FlutterSecureStorage storage,
  })  : _dio = dio,
        _secureStorage = storage;

  /// Retrieves the current access token from secure storage
  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return token;
    } catch (e, stackTrace) {
      _logger.error('Error reading access token',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Retrieves the current refresh token from secure storage
  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      return token;
    } catch (e, stackTrace) {
      _logger.error('Error reading refresh token',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Saves the access token to secure storage
  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      _logger.debug('Access token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('Error saving access token',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to save access token');
    }
  }

  /// Saves the refresh token to secure storage
  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
      _logger.debug('Refresh token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('Error saving refresh token',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to save refresh token');
    }
  }

  /// Deletes the access token from secure storage
  @override
  Future<void> deleteAccessToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      _logger.debug('Access token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('Error deleting access token',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Deletes the refresh token from secure storage
  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
      _logger.debug('Refresh token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('Error deleting refresh token',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Checks if the current token is valid by verifying with the backend
  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        _logger.debug('No token found in storage');
        return false;
      }

      // Use the dedicated token verification endpoint
      final response = await _dio.post(
        TokenApiRoutes.verify,
        data: {'token': token},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        _logger.debug('Token is valid, user is authenticated');
        return true;
      } else if (response.statusCode == 401) {
        _logger.debug('Token expired, attempting refresh');
        return refreshToken();
      } else {
        _logger.error(
            'Token validation failed with status: ${response.statusCode}');
      }

      return false;
    } catch (e, stackTrace) {
      _logger.error('Error during token validation',
          error: e, stackTrace: stackTrace);
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        _logger.error('Could not connect to server. Is the backend running?');
      }
      return false;
    }
  }

  /// Attempts to refresh the access token using the refresh token
  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        _logger.debug('No refresh token found');
        return false;
      }

      _logger
          .debug('Sending refresh token request to: ${TokenApiRoutes.refresh}');
      final response = await _dio.post(
        TokenApiRoutes.refresh,
        data: {'refresh': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['access_token'] != null) {
          _logger.debug('Token refresh successful');
          await saveAccessToken(data['access_token']);

          // If a new refresh token is provided, save it
          if (data['refresh_token'] != null) {
            await saveRefreshToken(data['refresh_token']);
          }

          return true;
        }
      }

      // If refresh failed, clear tokens
      await Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
      ]);

      _logger.error('Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e, stackTrace) {
      _logger.error('Error refreshing token', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
