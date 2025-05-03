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

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip authentication for token-related endpoints
    final path = options.path.toLowerCase();
    if (path.contains(AuthApiRoutes.login) ||
        path.contains(AuthApiRoutes.register) ||
        path.contains(TokenApiRoutes.refresh) ||
        path.contains(TokenApiRoutes.verify)) {
      _logger
          .debug('[AuthInterceptor] Skipping auth for path: ${options.path}');
      return super.onRequest(options, handler);
    }

    try {
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.debug(
            '[AuthInterceptor] Added auth token to request: ${options.path}');
      } else {
        _logger.warning(
            '[AuthInterceptor] No auth token available for request: ${options.path}');
        _logger.warning(
            ' [AuthInterceptor] :No auth token available for request: ${options.path}');
      }
    } catch (e) {
      _logger.error(' [AuthInterceptor] :Error adding auth token to request',
          error: e);
      // Continue with the request without the token, let the error handling middleware deal with it
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      // Skip token refresh for token-related endpoints to avoid loops
      if (err.requestOptions.path.contains(TokenApiRoutes.refresh) ||
          err.requestOptions.path.contains(TokenApiRoutes.verify)) {
        _logger.warning(
            ' [AuthInterceptor] :Skipping token refresh for token endpoint');
        return handler.next(err);
      }

      _logger.warning(
          ' [AuthInterceptor] :Received 401 Unauthorized response for ${err.requestOptions.path}');

      try {
        // Try to refresh the token - our improved TokenService handles locking
        final refreshed = await _tokenService.refreshToken();
        if (refreshed) {
          _logger.info(
              ' [AuthInterceptor] :Token refreshed successfully, retrying request');

          // Get the new token
          final newToken = await _tokenService.getAccessToken();
          if (newToken != null) {
            // Clone the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Create a new Dio instance for the retry to avoid interceptor loops
            final dio = Dio();

            try {
              // Retry the request with the new token
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (retryError) {
              _logger.error(
                  ' [AuthInterceptor] :Error retrying request after token refresh',
                  error: retryError);
              // If retry fails, continue with the original error
            }
          }
        } else {
          _logger.warning(
              ' [AuthInterceptor] :Token refresh failed, proceeding with error');
        }
      } catch (e) {
        _logger.error(' [AuthInterceptor] :Error during token refresh',
            error: e);
      }
    }

    // If we couldn't handle the error, pass it on
    return handler.next(err);
  }

  @override
  String toString() => 'AuthInterceptor';
}
