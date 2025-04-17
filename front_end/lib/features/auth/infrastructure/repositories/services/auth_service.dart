import 'package:dio/dio.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/infrastructure/models/auth_model.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';

/// Handles authentication operations like login, register, and logout
class AuthService {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  final AppLogger _logger = AppLogger();

  AuthService({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  /// Authenticates a user with email and password
  /// Returns an AuthTokens object on success
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.debug('Sending login request for user: $email');

      // Use the ApiClient to handle the request
      final data = await _apiClient.post<Map<String, dynamic>>(
        AuthApiRoutes.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      _logger.debug('Login successful');
      _logger.debug('Login response data: $data');

      // Parse the response using our model
      final authTokens = AuthTokensModel.fromJson(data);

      // Save tokens
      _logger.debug('Saving access and refresh tokens');
      await _tokenService.saveAccessToken(authTokens.accessToken);
      await _tokenService.saveRefreshToken(authTokens.refreshToken);

      _logger.debug('Tokens saved successfully');

      // Return domain entity
      return authTokens.toEntity();
    } catch (e, stackTrace) {
      // The ApiClient now throws domain-specific exceptions
      // We can add additional logging or handling here if needed
      _logger.error('Login error', error: e, stackTrace: stackTrace);

      // Re-throw the domain exception - it will be handled by the repository layer
      rethrow;
    }
  }

  /// Registers a new user with the provided information
  /// Returns the created AuthTokens object on success
  Future<AuthTokens> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) async {
    try {
      _logger.debug('Sending registration request for user: $email');

      // Prepare request data
      final requestData = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'profile_photo_url': profilePhotoUrl,
      };

      // Remove null values
      requestData.removeWhere((key, value) => value == null);

      // Use the ApiClient to handle the request
      final data = await _apiClient.post<Map<String, dynamic>>(
        AuthApiRoutes.register,
        data: requestData,
      );

      _logger.debug('Registration successful');
      _logger.debug('Registration response data: $data');

      // Parse the response using our model
      final authTokens = AuthTokensModel.fromJson(data);

      // Save tokens
      await _tokenService.saveAccessToken(authTokens.accessToken);
      await _tokenService.saveRefreshToken(authTokens.refreshToken);

      // Return domain entity
      return authTokens.toEntity();
    } catch (e, stackTrace) {
      // The ApiClient now throws domain-specific exceptions
      _logger.error('Registration error', error: e, stackTrace: stackTrace);

      // Re-throw the domain exception - it will be handled by the repository layer
      rethrow;
    }
  }

  /// Logs out the current user and invalidates their tokens
  Future<void> logout() async {
    try {
      // Get both access and refresh tokens
      final accessToken = await _tokenService.getAccessToken();
      final refreshToken = await _tokenService.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        // Send the refresh token in the request body as required by the backend
        // The user ID will be extracted from the access token on the backend
        await _apiClient.post<Map<String, dynamic>>(
          AuthApiRoutes.logout,
          data: {
            'refresh_token': refreshToken,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $accessToken',
          }),
        );
        _logger.debug('Logout request sent successfully');
      } else {
        _logger
            .warning('Missing tokens for logout, clearing local storage only');
      }

      // Always clear local tokens
      await Future.wait([
        _tokenService.deleteAccessToken(),
        _tokenService.deleteRefreshToken(),
      ]);
      _logger.debug('Successfully cleared all tokens');
    } catch (e, stackTrace) {
      _logger.error('Error during logout', error: e, stackTrace: stackTrace);
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }
}
