import 'dart:async';
import 'package:dio/dio.dart';
import 'package:semo/core/domain/services/secure_token_storage.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/infrastructure/utils/token_cache.dart';
import 'package:semo/core/infrastructure/utils/jwt_helper.dart';
import 'package:semo/core/utils/logger.dart';

/// Implementation of the TokenService interface
///
/// This class handles token management operations including:
/// - Token storage and retrieval
/// - Token validation and refresh
/// - Token caching for performance
class TokenServiceImpl implements TokenService {
  final Dio _dio;
  final TokenStorage _storage;
  final TokenCache _cache;
  final AppLogger _logger;

  // Locking mechanism to prevent multiple simultaneous token refresh attempts
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  /// Creates a new TokenServiceImpl instance
  TokenServiceImpl({
    required Dio dio,
    required TokenStorage storage,
    TokenCache? cache,
    AppLogger? logger,
  })  : _dio = dio,
        _storage = storage,
        _cache = cache ?? TokenCache(),
        _logger = logger ?? AppLogger();

  /// Retrieves the current access token from cache or storage
  @override
  Future<String?> getAccessToken() async {
    // Return cached token if available
    if (_cache.hasAccessToken()) {
      _logger.debug('[TokenService] Using cached access token');
      return _cache.accessToken;
    }

    try {
      final token = await _storage.getAccessToken();
      if (token != null) {
        // Cache the token for future use
        _cache.accessToken = token;
        _logger.debug(
            '[TokenService] Access token retrieved from storage and cached');
      }
      return token;
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error reading access token',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Retrieves the current refresh token from cache or storage
  @override
  Future<String?> getRefreshToken() async {
    // Return cached token if available
    if (_cache.hasRefreshToken()) {
      _logger.debug('[TokenService] Using cached refresh token');
      return _cache.refreshToken;
    }

    try {
      final token = await _storage.getRefreshToken();
      if (token != null) {
        // Cache the token for future use
        _cache.refreshToken = token;
        _logger.debug(
            '[TokenService] Refresh token retrieved from storage and cached');
      }
      return token;
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error reading refresh token',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Saves the access token to storage and cache
  /// Also extracts and saves the token expiry time
  @override
  Future<void> saveAccessToken(String token) async {
    try {
      // Update the in-memory cache first
      _cache.accessToken = token;

      // Extract token expiry from JWT if possible
      final expiryDate = JwtHelper.extractExpiry(token);
      if (expiryDate != null) {
        _cache.accessTokenExpiry = expiryDate;
        await _storage.saveTokenExpiry(expiryDate);
        _logger.debug(
            '[TokenService] Token expiry extracted and saved: ${expiryDate.toIso8601String()}');
      }

      // Save the token to secure storage
      await _storage.saveAccessToken(token);
      _logger.debug('[TokenService] Access token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error saving access token',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to save access token');
    }
  }

  /// Saves the refresh token to storage and cache
  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      // Update the in-memory cache first
      _cache.refreshToken = token;

      // Save to secure storage
      await _storage.saveRefreshToken(token);
      _logger.debug('[TokenService] Refresh token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error saving refresh token',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to save refresh token');
    }
  }

  /// Deletes the access token from storage and cache
  @override
  Future<void> deleteAccessToken() async {
    try {
      // Clear from storage
      await _storage.deleteAccessToken();
      await _storage.deleteTokenExpiry();

      // Clear from cache
      _cache.accessToken = null;
      _cache.accessTokenExpiry = null;

      _logger.debug('[TokenService] Access token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error deleting access token',
          error: e, stackTrace: stackTrace);
      // Still clear the cache even if storage deletion fails
      _cache.accessToken = null;
      _cache.accessTokenExpiry = null;
    }
  }

  /// Deletes the refresh token from storage and cache
  @override
  Future<void> deleteRefreshToken() async {
    try {
      // Clear from storage
      await _storage.deleteRefreshToken();

      // Clear from cache
      _cache.refreshToken = null;

      _logger.debug('[TokenService] Refresh token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error deleting refresh token',
          error: e, stackTrace: stackTrace);
      // Still clear the cache even if storage deletion fails
      _cache.refreshToken = null;
    }
  }

  /// Clears all tokens from storage and cache
  @override
  Future<void> clearAllTokens() async {
    try {
      // Clear from storage
      await _storage.clearAllTokens();

      // Clear from cache
      _cache.clear();

      _logger.debug('[TokenService] All tokens cleared successfully');
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error clearing all tokens',
          error: e, stackTrace: stackTrace);
      // Still clear the cache even if storage deletion fails
      _cache.clear();
    }
  }

  /// Checks if the current token is valid and not about to expire
  /// Will proactively refresh tokens that are about to expire
  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        _logger.debug('[TokenService] No token found in storage');
        return false;
      }

      // Check if token is about to expire (if we have expiry info)
      if (_cache.hasTokenExpiry()) {
        final now = DateTime.now();
        final expiresIn = _cache.accessTokenExpiry!.difference(now);

        // If token expires in less than 1 minute, refresh it proactively
        if (JwtHelper.isAboutToExpire(_cache.accessTokenExpiry!)) {
          _logger.debug(
              '[TokenService] Token expires in ${expiresIn.inSeconds} seconds, refreshing proactively');
          return await refreshToken();
        }

        // If token is not expired yet, it's valid
        if (!JwtHelper.isExpired(_cache.accessTokenExpiry!)) {
          _logger.debug(
              '[TokenService] Token is valid (expires in ${expiresIn.inMinutes} minutes)');
          return true;
        } else {
          _logger.debug('[TokenService] Token has expired, attempting refresh');
          return await refreshToken();
        }
      }

      // If we don't have expiry info, verify with the backend
      try {
        final response = await _dio.post(
          TokenApiRoutes.verify,
          data: {'token': token},
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (response.statusCode == 200) {
          _logger.debug('[TokenService] Token is valid (verified by backend)');
          return true;
        } else if (response.statusCode == 401) {
          _logger.debug('[TokenService] Token expired, attempting refresh');
          return await refreshToken();
        } else {
          _logger.error(
              '[TokenService] Token validation failed with status: ${response.statusCode}');
        }
      } catch (verifyError) {
        _logger.error('[TokenService] Error verifying token with backend',
            error: verifyError);
        // If we can't verify with backend, try to refresh anyway
        return await refreshToken();
      }

      return false;
    } catch (e, stackTrace) {
      _logger.error('[TokenService] Error during token validation',
          error: e, stackTrace: stackTrace);
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        _logger.error(
            '[TokenService] Could not connect to server. Is the backend running?');
      }
      return false;
    }
  }

  /// Attempts to refresh the access token using the refresh token
  /// Uses a locking mechanism to prevent multiple simultaneous refresh attempts
  @override
  Future<bool> refreshToken() async {
    // If a refresh is already in progress, wait for it to complete and return its result
    if (_isRefreshing) {
      _logger.debug(
          '[TokenService] Token refresh already in progress, waiting for result');
      return await _refreshCompleter!.future;
    }

    // Set up the locking mechanism
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        _logger.debug('[TokenService] No refresh token found');
        _completeRefresh(false);
        return false;
      }

      _logger.debug(
          '[TokenService] Sending refresh token request to: ${TokenApiRoutes.refresh}');
      _logger.debug(
          '[TokenService] Refresh token payload: {"refresh": "${refreshToken.substring(0, 10)}..."}');

      try {
        // First, delete the current access token to prevent conflicts
        await deleteAccessToken();

        final response = await _dio.post(
          TokenApiRoutes.refresh,
          data: {'refresh': refreshToken},
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        _logger.debug(
            '[TokenService] Token refresh response status: ${response.statusCode}');
        _logger.debug(
            '[TokenService] Token refresh response data: ${response.data}');

        if (response.statusCode == 200) {
          final data = response.data;

          // Check both possible field names (access_token and access)
          final accessToken = data['access_token'] ?? data['access'];
          final newRefreshToken = data['refresh_token'] ?? data['refresh'];

          if (accessToken != null) {
            _logger.debug(
                '[TokenService] Token refresh successful, received access token');

            // Save the access token with retry logic
            bool tokenSaved = false;
            int retryCount = 0;
            while (!tokenSaved && retryCount < 3) {
              try {
                await saveAccessToken(accessToken);
                tokenSaved = true;
              } catch (e) {
                retryCount++;
                _logger.warning(
                    '[TokenService] Failed to save access token, retry $retryCount/3');
                await Future.delayed(Duration(milliseconds: 100 * retryCount));
              }
            }

            if (!tokenSaved) {
              _logger.error(
                  '[TokenService] Failed to save access token after retries');
              _completeRefresh(false);
              return false;
            }

            // If a new refresh token is provided, save it
            if (newRefreshToken != null) {
              try {
                // Delete old refresh token first
                await deleteRefreshToken();
                await Future.delayed(const Duration(milliseconds: 100));

                await saveRefreshToken(newRefreshToken);
                _logger.debug(
                    '[TokenService] New refresh token received and saved');
              } catch (e) {
                _logger.error('[TokenService] Failed to save new refresh token',
                    error: e);
                // Continue anyway since we have a valid access token
              }
            } else {
              _logger.debug(
                  '[TokenService] No new refresh token received, keeping existing one');
            }

            _completeRefresh(true);
            return true;
          } else {
            _logger.error(
                '[TokenService] Token refresh response missing access token');
          }
        }

        // If we get here, refresh failed but no exception was thrown
        _logger.error(
            '[TokenService] Token refresh failed with status: ${response.statusCode}');

        // Clear tokens
        await clearAllTokens();

        _completeRefresh(false);
        return false;
      } catch (e) {
        if (e is DioException) {
          _logger.error('[TokenService] Token refresh DioException', error: e);
          if (e.response != null) {
            _logger.error(
                '[TokenService] Response status: ${e.response?.statusCode}');
            _logger.error('[TokenService] Response data: ${e.response?.data}');
          } else {
            _logger.error('[TokenService] No response data available');
          }
        } else {
          _logger.error(
              '[TokenService] Token refresh failed with unexpected error',
              error: e);
        }

        // Clear tokens on error
        await clearAllTokens();

        _completeRefresh(false);
        return false;
      }
    } catch (e) {
      _logger.error('[TokenService] Token refresh outer exception', error: e);
      _completeRefresh(false);
      return false;
    }
  }

  /// Helper method to complete the refresh operation and release the lock
  void _completeRefresh(bool result) {
    _refreshCompleter?.complete(result);
    _isRefreshing = false;
    _refreshCompleter = null;
  }
}
