import 'package:dio/dio.dart';

/// Interface for API client that handles all network requests
/// This follows the Dependency Inversion Principle by defining the interface in the domain layer
abstract class ApiClient {
  /// Performs a GET request to the specified endpoint
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  /// Performs a POST request to the specified endpoint
  Future<T> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  /// Performs a PUT request to the specified endpoint
  Future<T> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  /// Performs a PATCH request to the specified endpoint
  Future<T> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  /// Performs a DELETE request to the specified endpoint
  Future<T> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
}
