import 'package:dio/dio.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';
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

  /// Performs login with email and password
  /// Returns AuthTokens on success
  /// Throws domain-specific exceptions on failure
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      // Send login request to API
      final data = await _apiClient.post<Map<String, dynamic>>(
        AuthApiRoutes.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Parse response and save tokens
      final authTokens = AuthTokensModel.fromJson(data);

      // Save tokens securely
      await _tokenService.saveAccessToken(authTokens.accessToken);
      await _tokenService.saveRefreshToken(authTokens.refreshToken);

      // Return domain entity
      return authTokens.toEntity();
    } catch (e) {
      // Convert API exceptions to domain exceptions without logging
      // Logging will be handled by the repository layer
      return _mapApiExceptionToDomainException(e);
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

  /// Maps API exceptions to domain-specific auth exceptions
  Never _mapApiExceptionToDomainException(dynamic e) {
    if (e is UnauthorizedException) {
      throw InvalidCredentialsException(
        message: e.message,
        code: e.code,
        requestId: e.requestId,
      );
    } else if (e is BadRequestException) {
      throw ValidationException(
        message: e.message,
        validationErrors: e.validationErrors,
        code: e.code,
        requestId: e.requestId,
      );
    } else if (e is ApiServerException) {
      throw ServerException(
        message: e.message,
        code: e.code,
        requestId: e.requestId,
      );
    } else if (e is ApiNetworkException || e is ApiTimeoutException) {
      throw NetworkException(
        message: e is ApiException ? e.message : 'Network error',
        code: e is ApiException ? e.code : 'network_error',
        requestId: e is ApiException ? e.requestId : null,
      );
    } else {
      // Generic fallback for any other types of errors
      throw AuthenticationException('Authentication error: ${e.toString()}');
    }
  }
}
