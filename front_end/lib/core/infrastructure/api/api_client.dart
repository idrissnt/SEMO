import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/infrastructure/models/error_response_model.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';

/// A centralized API client for handling all network requests
/// Provides consistent error handling, authentication, and logging
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final AppLogger _logger;

  ApiClient({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
    required AppLogger logger,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _logger = logger {
    _setupInterceptors();
  }

  /// Sets up request/response interceptors for authentication and logging
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token if available
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log outgoing requests in debug mode
          _logger.debug('API Request: ${options.method} ${options.uri}');
          if (options.data != null) {
            _logger.debug('Request Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log successful responses in debug mode
          _logger.debug(
              'API Response: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Handle authentication errors (401)
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              return handler.resolve(await _retry(error.requestOptions));
            }
          }

          // Log errors
          _logger.error(
            'API Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
            error: error,
            stackTrace: error.stackTrace,
          );

          return handler.next(error);
        },
      ),
    );
  }

  /// Attempts to refresh the authentication token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        TokenApiRoutes.refresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access'];
        await _secureStorage.write(key: 'access_token', value: newToken);
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Token refresh failed', error: e);
      return false;
    }
  }

  /// Retries a failed request with updated authentication
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _secureStorage.read(key: 'access_token');
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Performs a GET request to the specified endpoint
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

  /// Handles API errors and maps them to domain exceptions
  T _handleError<T>(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response != null) {
        final statusCode = response.statusCode;
        final path = response.requestOptions.path;
        
        _logger.error(
          'API Error: $statusCode $path',
          error: error,
        );
        
        // Parse error response
        final errorResponse = ErrorResponseModel.fromDioError(error);
        final errorMessage = errorResponse?.error ?? 'Unknown error';
        final errorCode = errorResponse?.code;
        final requestId = errorResponse?.requestId;
        final details = errorResponse?.details;
        
        // Map status codes to domain exceptions
        switch (statusCode) {
          case 400:
            throw ValidationException(
              message: errorMessage,
              validationErrors: details,
              code: errorCode,
              requestId: requestId
            );
          case 401:
            throw InvalidCredentialsException(
              message: errorMessage,
              code: errorCode,
              requestId: requestId
            );
          case 403:
            throw AuthorizationException(
              message: errorMessage,
              code: errorCode,
              requestId: requestId
            );
          case 404:
            throw GenericDomainException(
              'Resource not found: $path',
              code: errorCode ?? 'not_found',
              requestId: requestId
            );
          case 500:
          case 502:
          case 503:
          case 504:
            throw ServerException(
              message: errorMessage,
              code: errorCode,
              requestId: requestId
            );
          default:
            throw GenericDomainException(
              'Request failed with status: $statusCode, message: $errorMessage',
              code: errorCode,
              requestId: requestId
            );
        }
      } else {
        _logger.error('API Error: No response', error: error);
        throw NetworkException(
          message: 'No response from server: ${error.message}',
          code: 'connection_error'
        );
      }
    } else {
      _logger.error('API Error: Unknown error', error: error);
      throw GenericDomainException('Unknown error: $error', code: 'unknown_error');
    }
  }
}
