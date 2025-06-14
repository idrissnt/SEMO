import 'package:dio/dio.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/infrastructure/models/auth_model.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/features/auth/domain/exceptions/auth/auth_exception_mapper.dart';

/// Handles authentication operations like login, register, and logout
class AuthService {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  final AppLogger _logger;
  final AuthExceptionMapper _exceptionMapper;

  final String logName = 'AuthService';

  AuthService({
    required ApiClient apiClient,
    required TokenService tokenService,
    required AppLogger logger,
    required AuthExceptionMapper exceptionMapper,
  })  : _apiClient = apiClient,
        _tokenService = tokenService,
        _logger = logger,
        _exceptionMapper = exceptionMapper;

  /// Performs login with email and password
  /// Returns AuthTokens on success
  /// Throws domain-specific exceptions on failure
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.debug(' [$logName] : Sending login request for user: $email');
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

      _logger.debug(' [$logName] : Login successful for user: $email');

      // Return domain entity
      return authTokens.toEntity();
    } catch (e) {
      // Convert API exceptions to domain exceptions
      // Logging will be handled by the repository layer
      _logger.error(' [$logName] : Failed to login', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
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
      _logger
          .debug(' [$logName] : Sending registration request for user: $email');
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

      _logger.debug(' [$logName] : Registration successful for user: $email');

      // Parse the response using our model
      final authTokens = AuthTokensModel.fromJson(data);

      // Save tokens
      await _tokenService.saveAccessToken(authTokens.accessToken);
      await _tokenService.saveRefreshToken(authTokens.refreshToken);

      // Return domain entity
      return authTokens.toEntity();
    } catch (e) {
      // Map API exceptions to domain exceptions
      _logger.error(' [$logName] : Failed to register', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Logs out the current user and invalidates their tokens
  Future<void> logout(
    String email,
  ) async {
    try {
      _logger.debug(' [$logName] : Sending logout request for user: $email');

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
        _logger.debug(' [$logName] : Logout successful for user: $email');
      } else {
        _logger.warning(
            ' [$logName] : Missing tokens for logout, clearing local storage only');
      }

      // Always clear local tokens
      await Future.wait([
        _tokenService.deleteAccessToken(),
        _tokenService.deleteRefreshToken(),
      ]);
      _logger.debug(' [$logName] : Successfully cleared all tokens');
    } catch (e) {
      _logger.error(' [$logName] : Failed to logout', error: e);
      _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }
}
