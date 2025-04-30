import 'package:dio/dio.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:meta/meta.dart';

/// Interceptor that adds authentication token to requests
///
/// This interceptor handles:
/// 1. Adding authentication tokens to requests
/// 2. Skipping authentication for specific endpoints
/// 3. Refreshing tokens when they expire
/// 4. Retrying failed requests after token refresh
@immutable
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final AppLogger _logger;

  const AuthInterceptor({
    required TokenService tokenService,
    required AppLogger logger,
  })  : _tokenService = tokenService,
        _logger = logger;

  /// List of endpoints that don't require authentication
  static final List<String> _noAuthEndpoints = [
    AuthApiRoutes.login,
    AuthApiRoutes.register,
    TokenApiRoutes.refresh,
    TokenApiRoutes.verify,
  ];

  /// Checks if the given path matches any of the no-auth endpoints
  bool _isNoAuthEndpoint(String path) {
    return _noAuthEndpoints.any((endpoint) => path.contains(endpoint));
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip authentication for endpoints that don't require it
    if (_isNoAuthEndpoint(options.path)) {
      _logger.debug('Skipping auth for endpoint: ${options.path}');
      return handler.next(options);
    }

    try {
      // Check if we have a valid token
      final hasValidToken = await _tokenService.hasValidToken();

      if (!hasValidToken) {
        // Try to refresh the token if it's invalid
        final refreshed = await _tokenService.refreshToken();
        if (!refreshed) {
          _logger.warning('Token refresh failed for request: ${options.path}');
          // Continue with the request, the server will handle unauthorized access
        }
      }

      // Get the token (possibly refreshed)
      final token = await _tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.debug('Added auth token to request: ${options.path}');
      } else {
        _logger.warning('No auth token available for request: ${options.path}');
      }
    } catch (e) {
      _logger.error('Error adding auth token to request', error: e);
      // Continue with the request without the token, let the error handling middleware deal with it
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      _logger.warning('Received 401 Unauthorized response');

      try {
        // Try to refresh the token
        final refreshed = await _tokenService.refreshToken();
        if (refreshed) {
          _logger.info('Token refreshed successfully, retrying request');

          // Get the new token
          final newToken = await _tokenService.getAccessToken();
          if (newToken != null) {
            // Clone the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Retry the request with the new token
            final response = await Dio().fetch(options);
            return handler.resolve(response);
          }
        } else {
          _logger.warning('Token refresh failed, proceeding with error');
        }
      } catch (e) {
        _logger.error('Error during token refresh', error: e);
      }
    }

    // If we couldn't handle the error, pass it on
    return handler.next(err);
  }

  @override
  String toString() => 'AuthInterceptor';
}
