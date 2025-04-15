import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/infrastructure/models/auth_model.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/core/infrastructure/services/token_service.dart';

/// Type definition for a function that takes a token and userId and returns a Future of type T
typedef AuthenticatedRequestFn<T> = Future<T> Function(
    String token, String userId);

class UserService {
  final Dio _dio;
  final TokenService _tokenService;
  final AppLogger _logger = AppLogger();

  UserService({
    required Dio dio,
    required TokenService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  /// Retrieves the current user's profile information
  Future<User> getCurrentUser() async {
    return _authenticatedRequest<User>(
      requestFn: (token, userId) async {
        _logger.debug('Fetching profile for user ID: $userId');

        final response = await _dio.get(
          '${ProfileApiRoutes.base}$userId/',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          }),
        );

        return _handleUserResponse(response, 'get user profile');
      },
      operationName: 'getCurrentUser',
    );
  }

  /// Helper method to handle authenticated requests with token refresh capability
  Future<T> _authenticatedRequest<T>({
    required AuthenticatedRequestFn<T> requestFn,
    required String operationName,
  }) async {
    try {
      // Get the access token for authentication
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        _logger.error('No authentication token found');
        throw Exception('No authentication token found');
      }

      // Get the user ID from the token
      final String userId = await _getUserIdFromToken(token);

      try {
        // Execute the request function
        return await requestFn(token, userId);
      } on DioException catch (e) {
        // Handle 401 Unauthorized errors by refreshing the token
        if (e.response?.statusCode == 401) {
          _logger.debug('Token expired, attempting to refresh');

          final refreshed = await _tokenService.refreshToken();
          if (refreshed) {
            _logger.debug('Token refreshed, retrying $operationName');
            // Get the new token and retry the request
            final newToken = await _tokenService.getAccessToken();
            if (newToken != null) {
              return await requestFn(newToken, userId);
            }
          }
          throw Exception('Authentication failed after token refresh attempt');
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      _logger.error('Error during $operationName',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to $operationName: ${e.toString()}');
    }
  }

  /// Helper method to extract the user ID from a JWT token
  Future<String> _getUserIdFromToken(String token) async {
    try {
      // JWT tokens have three parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token format');
      }

      // The payload is the second part (index 1)
      final payload = parts[1];

      // The payload is base64Url encoded, so we need to decode it
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      // Parse the JSON
      final Map<String, dynamic> data = jsonDecode(decoded);

      // Extract the user ID - the field name depends on our JWT configuration
      // Common field names are 'sub', 'user_id', or 'id'.
      final userId = data['user_id'] ?? data['sub'] ?? data['id'];

      if (userId == null) {
        throw Exception('User ID not found in token');
      }

      return userId.toString();
    } catch (e, stackTrace) {
      _logger.error('Error extracting user ID from token',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to extract user ID from token: ${e.toString()}');
    }
  }

  /// Helper method to handle user response parsing
  User _handleUserResponse(Response response, String operation) {
    if (response.statusCode == 200) {
      final data = response.data;
      final user = UserModel.fromJson(data).toEntity();
      _logger.debug('Successfully completed: $operation');
      return user;
    } else {
      final errorMessage = response.data is Map
          ? response.data['detail'] ??
              response.data['error'] ??
              'Failed to $operation'
          : 'Failed to $operation';
      _logger.error('Failed to $operation: ${response.statusCode}');
      throw Exception(errorMessage);
    }
  }
}
