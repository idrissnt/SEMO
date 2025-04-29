import 'package:dio/dio.dart';

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/infrastructure/models/error_response_model.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/domain/services/api_client.dart';

/// Implementation of the ApiClient interface for handling all network requests
/// Provides consistent error handling, authentication, and logging
class ApiClientImpl implements ApiClient {
  final Dio _dio;
  final AppLogger _logger;

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
      if (T == dynamic || response.data is T) {
        return response.data as T;
      } else if (response.data == null) {
        throw Exception('Response data is null');
      } else {
        throw Exception(
            'Type mismatch: Expected $T but got ${response.data.runtimeType}');
      }
    } else {
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
          code: 'timeout',
        );
      } else {
        throw ApiNetworkException(
          message: error.message ?? 'Network error',
          code: 'network_error',
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
        'API Error: ${statusCode ?? 'Unknown'} ${error.requestOptions.uri}',
        error: _getCleanErrorMessage(error),
      );

      if (response != null) {
        // Parse error response
        final errorResponse = ErrorResponseModel.fromDioError(error);
        final errorMessage = errorResponse?.error ?? 'Unknown error';
        final errorCode = errorResponse?.code;
        final requestId = errorResponse?.requestId;
        final details = errorResponse?.details;

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
        _logger.error('API Error: No response', error: error);
        throw ApiNetworkException(
            message: 'No response from server: ${error.message}',
            code: 'connection_error');
      }
    } else {
      _logger.error('API Error: Unknown error', error: error);
      throw ApiException('Unknown error: $error', code: 'unknown_error');
    }
  }
}
