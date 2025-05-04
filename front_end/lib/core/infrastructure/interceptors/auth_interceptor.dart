import 'package:dio/dio.dart';
import 'package:semo/core/domain/exceptions/api_error_code.dart';
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

  final String logFileName = 'AuthInterceptor';

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip authentication for token-related endpoints
    final path = options.path.toLowerCase();
    if (path.contains(AuthApiRoutes.login) ||
        path.contains(AuthApiRoutes.register) ||
        path.contains(TokenApiRoutes.refresh) ||
        path.contains(TokenApiRoutes.verify)) {
      //
      _logger.debug('$logFileName: Skipping auth for path: ${options.path}');
      return handler.next(options);
    }

    try {
      // Centralized token management - only the interceptor should access tokens directly
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.debug(
            '$logFileName: Added auth token to request: ${options.path}');
      } else {
        _logger.warning(
            '$logFileName: No auth token available for request: ${options.path}');
      }
    } catch (e) {
      _logger.error('$logFileName: Error adding auth token to request',
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
        _logger
            .debug('$logFileName: Skipping token refresh for token endpoint');
        return handler.next(err);
      }

      _logger.warning(
          '$logFileName: Received 401 Unauthorized response for ${err.requestOptions.path}');

      // First check if this is a user not found error
      if (_isUserNotFoundError(err)) {
        return _handleUserNotFoundError(handler, err);
      }

      try {
        // Try to refresh the token
        final refreshed = await _tokenService.refreshToken();
        if (!refreshed) {
          _logger.warning(
              '$logFileName: Token refresh failed, proceeding with error');
          return handler.next(err);
        }

        _logger.info(
            '$logFileName: Token refreshed successfully, retrying request');

        // Get the new token
        final newToken = await _tokenService.getAccessToken();
        if (newToken == null) {
          _logger.warning('$logFileName: No new token available after refresh');
          return handler.next(err);
        }

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
              '$logFileName: Error retrying request after token refresh',
              error: retryError);

          // Check if this is a user not found error
          if (_isUserNotFoundError(retryError)) {
            return _handleUserNotFoundError(
                handler, retryError as DioException);
          }
        }
      } catch (e) {
        _logger.error('$logFileName: Error during token refresh', error: e);

        // Check if this is a user not found error
        if (_isUserNotFoundError(e)) {
          return _handleUserNotFoundError(handler, e as DioException);
        }
      }
    }

    // If we couldn't handle the error, pass it on
    return handler.next(err);
  }

  /// Helper method to handle user not found errors
  /// Creates a standardized error response and clears tokens
  Future<void> _handleUserNotFoundError(
    ErrorInterceptorHandler handler,
    DioException exception,
  ) async {
    _logger.warning(
        '$logFileName: User not found error detected, clearing tokens');

    // Clear all tokens since the user doesn't exist anymore
    await _tokenService.clearAllTokens();

    // Create a standardized error response
    final response = exception.response;
    final requestOptions = exception.requestOptions;

    // Create a properly formatted response with the correct status code
    final updatedResponse = Response(
      data: {'code': ErrorCodes.userNotFound, 'message': 'User not found'},
      statusCode: 404, // Use 404 to ensure it's mapped to NotFoundException
      requestOptions: requestOptions,
      headers: response?.headers ?? Headers(),
      isRedirect: response?.isRedirect ?? false,
      statusMessage: 'User not found',
      redirects: response?.redirects ?? [],
      extra: response?.extra ?? {},
    );

    // Reject the request with the standardized error
    return handler.reject(
      DioException(
        requestOptions: requestOptions,
        error: 'User not found in database. Authentication required.',
        response: updatedResponse,
        type: DioExceptionType.badResponse,
      ),
    );
  }

  /// Checks if an error is a user not found error
  bool _isUserNotFoundError(dynamic error) {
    if (error is! DioException) return false;
    if (error.response?.data == null) return false;

    // Handle different possible response formats
    final data = error.response!.data;

    _logger.warning('$logFileName: Received error response: $data');

    // Format 1: {"code": "user_not_found", ...}
    if (data is Map<String, dynamic>) {
      final errorCode = data['code'];
      final errorData = data['error'];

      // Direct match with userNotFound code
      if (errorCode == ErrorCodes.userNotFound) {
        _logger.warning('$logFileName: Direct match with user_not_found code');
        return true;
      }

      // Check for authentication_error code with nested user_not_found
      if (errorCode == ErrorCodes.authenticationError) {
        _logger.warning(
            '$logFileName: Found authentication_error code, checking details');

        // Format 2: Complex nested structure with error field as Map
        // {"error": {"detail": "ErrorDetail(string='User not found',...", "code": "ErrorDetail(string='user_not_found',..."}, ...}
        if (errorData is Map<String, dynamic>) {
          final nestedCode = errorData['code'];
          final nestedDetail = errorData['detail'];

          _logger.warning(
              '$logFileName: Nested error structure - code: $nestedCode, detail: $nestedDetail');

          if (nestedCode != null &&
              nestedCode.toString().contains('user_not_found')) {
            return true;
          }

          if (nestedDetail != null &&
              nestedDetail
                  .toString()
                  .toLowerCase()
                  .contains('user not found')) {
            return true;
          }
        }
        // Format 3: Complex nested structure with error field as String
        else if (errorData is String) {
          final errorStr = errorData.toLowerCase();
          if (errorStr.contains('user not found') ||
              errorStr.contains('user does not exist')) {
            return true;
          }
        }
      }

      // Format 4: Check message field
      final errorMessage = data['message'] ?? '';
      if (errorMessage is String) {
        final message = errorMessage.toLowerCase();
        if (message.contains('user not found') ||
            message.contains('user does not exist') ||
            message.contains('no user with this id')) {
          return true;
        }
      }
    }

    // Format 5: String error message
    if (data is String) {
      final message = data.toLowerCase();
      if (message.contains('user not found') ||
          message.contains('user does not exist') ||
          message.contains('no user with this id')) {
        return true;
      }
    }

    return false;
  }

  @override
  String toString() => 'AuthInterceptor';
}
