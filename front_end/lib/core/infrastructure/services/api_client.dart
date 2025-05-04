import 'package:dio/dio.dart';
import 'package:semo/core/domain/exceptions/api_error_code.dart';

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/infrastructure/models/error_response_model.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/domain/services/api_client.dart';

/// Implementation of the ApiClient interface for handling all network requests
/// Provides consistent error handling, authentication, and logging
class ApiClientImpl implements ApiClient {
  final Dio _dio;
  final AppLogger _logger;

  final String logFileName = 'ApiClient';

  ApiClientImpl({
    required Dio dio,
    required AppLogger logger,
  })  : _dio = dio,
        _logger = logger;

  /// Performs a GET request to the specified endpoint
  @override
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Performs a POST request to the specified endpoint
  @override
  Future<T> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Performs a PUT request to the specified endpoint
  @override
  Future<T> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Performs a DELETE request to the specified endpoint
  @override
  Future<T> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Performs a PATCH request to the specified endpoint
  @override
  Future<T> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handles successful API responses
  T _handleResponse<T>(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      _logger.debug(
          ' [$logFileName] : Request successful with status: ${response.statusCode}');
      if (T == dynamic || response.data is T) {
        _logger.debug(
            ' [$logFileName] : Response data is of type $T, returning it');
        return response.data as T;
      } else if (response.data == null) {
        _logger
            .debug(' [$logFileName] : Response data is null, returning null');
        throw Exception('Response data is null');
      } else {
        _logger.debug(
            ' [$logFileName] : Response data is of type ${response.data.runtimeType}, expected $T');
        throw Exception(
            'Type mismatch: Expected $T but got ${response.data.runtimeType}');
      }
    } else {
      _logger.debug(
          ' [$logFileName] : Request failed with status: ${response.statusCode}');
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  /// Extracts a clean error message from a DioException without the verbose details
  String _getCleanErrorMessage(DioException error) {
    if (error.response != null) {
      final errorResponse = ErrorResponseModel.fromDioError(error);
      return errorResponse?.error ?? 'Unknown error';
    } else {
      // Handle network errors (no response)
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw ApiTimeoutException(
          message: 'Request timed out',
          code: ErrorCodes.timeout,
        );
      } else {
        throw ApiNetworkException(
          message: error.message ?? 'Network error',
          code: ErrorCodes.networkError,
        );
      }
    }
  }

  /// Handles API errors and maps them to domain exceptions
  T _handleError<T>(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      // We use the URI instead of path for better error messages
      final statusCode = response?.statusCode;

      // Log a clean error message without the verbose Dio details
      _logger.error(
        '$logFileName: API Error: ${statusCode ?? 'Unknown'} ${error.requestOptions.uri}',
        error: _getCleanErrorMessage(error),
      );

      if (response != null) {
        // Parse error response
        final errorResponse = ErrorResponseModel.fromDioError(error);
        final errorMessage = errorResponse?.error ?? 'Unknown error';
        final errorCode = errorResponse?.code;
        final requestId = errorResponse?.requestId;
        final details = errorResponse?.details;

        // Check for user not found error regardless of status code
        // This allows the AuthInterceptor to properly handle these errors
        if (_isUserNotFoundError(error)) {
          _logger.warning(
              '$logFileName: User not found error detected in API client');
          throw NotFoundException(
            message: 'User not found in database',
            details: details,
            code: ErrorCodes.userNotFound,
            requestId: requestId,
          );
        }

        // Map HTTP status codes to generic API exceptions
        switch (statusCode) {
          case 401:
            throw UnauthorizedException(
              message: errorMessage,
              details: details,
              code: errorCode,
              requestId: requestId,
            );
          case 400:
            throw BadRequestException(
              message: errorMessage,
              validationErrors: details,
              code: errorCode,
              requestId: requestId,
            );
          case 500:
            throw ApiServerException(
              message: errorMessage,
              details: details,
              code: errorCode,
              requestId: requestId,
            );
          case 404:
            throw NotFoundException(
              message: errorMessage,
              details: details,
              code: errorCode,
              requestId: requestId,
            );
          case 409:
            throw ConflictException(
              message: errorMessage,
              details: details,
              code: errorCode,
              requestId: requestId,
            );
          default:
            throw ApiException(
                'Request failed with status: $statusCode, message: $errorMessage',
                statusCode: statusCode,
                details: details,
                code: errorCode,
                requestId: requestId);
        }
      } else {
        _logger.error(' [$logFileName] : API Error: No response', error: error);
        throw ApiNetworkException(
            message: 'No response from server: ${error.message}',
            code: ErrorCodes.networkError);
      }
    } else {
      _logger.error(' [$logFileName] : API Error: Unknown error', error: error);
      throw ApiException('Unknown error: $error', code: ErrorCodes.serverError);
    }
  }

  /// Checks if an error is a user not found error by examining the response data
  /// This handles various formats that might come from the backend
  bool _isUserNotFoundError(dynamic error) {
    if (error is! DioException) return false;
    if (error.response?.data == null) return false;

    // Handle different possible response formats
    final data = error.response!.data;

    // Format 1: {"code": "user_not_found", ...}
    if (data is Map<String, dynamic>) {
      final errorCode = data['code'];
      final errorData = data['error'];

      // Direct match with userNotFound code
      if (errorCode == ErrorCodes.userNotFound) {
        _logger
            .debug(' [$logFileName] : Direct match with user_not_found code');
        return true;
      }

      // Check for authentication_error code with nested user_not_found
      if (errorCode == ErrorCodes.authenticationError) {
        _logger.debug(
            ' [$logFileName] : Found authentication_error code, checking details');

        // Format 2: Complex nested structure with error field as Map
        // {"error": {"detail": "ErrorDetail(string='User not found',...", "code": "ErrorDetail(string='user_not_found',..."}, ...}
        if (errorData is Map<String, dynamic>) {
          final nestedCode = errorData['code'];
          final nestedDetail = errorData['detail'];

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
}
