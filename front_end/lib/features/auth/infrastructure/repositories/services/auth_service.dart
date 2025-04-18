import 'package:dio/dio.dart';
import 'package:semo/core/domain/exceptions/api_exceptions.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/services/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/exceptions/auth_error_codes.dart';
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
    } catch (e) {
      // Map API exceptions to domain exceptions
      return _mapApiExceptionToDomainException(e);
    }
  }

  /// Logs out the current user and invalidates their tokens
  Future<void> logout() async {
    try {
      // Get both access and refresh tokens
      final accessToken = await _tokenService.getAccessToken();
      final refreshToken = await _tokenService.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        // Send the refresh token in the request body for blacklisting a
        // specific token
        await _apiClient.post<Map<String, dynamic>>(
          AuthApiRoutes.logout,
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
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
    } catch (e) {
      _mapApiExceptionToDomainException(e);
    }
  }

  /// Maps API exceptions to domain-specific auth exceptions
  Never _mapApiExceptionToDomainException(dynamic e) {
    _logger.error('API Exception: ${e.message}, Code: ${e.code}');

    // First check for domain exceptions that might have been thrown already
    if (e is AuthenticationException) {
      // If it's already a domain exception, just rethrow it
      throw e;
    }

    // We override backend error codes with our frontend constants for consistency
    // The original code is still logged above for debugging purposes

    if (e is UnauthorizedException) {
      throw InvalidCredentialsException(
        message: e.message,
        // Override with our frontend constant for consistency
        code: AuthErrorCodes.invalidCredentials,
        requestId: e.requestId,
      );
    } else if (e is ConflictException) {
      throw UserAlreadyExistsException(
        message: e.message,
        code: AuthErrorCodes.userAlreadyExists,
        requestId: e.requestId,
      );
    } else if (e is BadRequestException) {
      // Check if this is related to missing refresh token
      if (e.message.toLowerCase().contains('refresh token')) {
        throw MissingRefreshTokenException(
          message: e.message,
          code: AuthErrorCodes.missingToken,
          requestId: e.requestId,
        );
      }
    } else if (e is ApiNetworkException || e is ApiTimeoutException) {
      // Handle network-specific errors
      // Determine the specific network error type
      final String networkCode = e is ApiTimeoutException
          ? ErrorCodes.timeout
          : ErrorCodes.networkError;

      throw GenericDomainException(
        e.message,
        code: networkCode, // Use our consistent error code
        requestId: e.requestId,
      );
    } else if (e is ApiServerException) {
      // Handle server-specific errors
      throw GenericDomainException(
        e.message,
        code: ErrorCodes.serverError, // Use our consistent error code
        requestId: e.requestId,
      );
    }

    // For all other cases, throw a generic domain exception
    throw GenericDomainException(
      e.message,
      code: AuthErrorCodes.genericError, // Use our consistent error code
      requestId: e.requestId,
    );
  }
}
