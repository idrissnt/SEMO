// No need for these imports as we're using dependency injection

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';

import 'package:semo/core/domain/exceptions/auth_exceptions.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/domain/services/token_service.dart';

import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/features/auth/infrastructure/repositories/services/auth_service.dart';

/// Implementation of the AuthRepository interface that delegates to specialized services
class UserAuthRepositoryImpl implements UserAuthRepository {
  final AuthService _authService;
  final AppLogger _logger;

  UserAuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenService tokenService,
    required AppLogger logger,
  })  : _logger = logger,
        _authService = AuthService(
          apiClient: apiClient,
          tokenService: tokenService,
        );

  @override
  Future<Result<AuthTokens, AuthenticationException>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authTokens =
          await _authService.login(email: email, password: password);
      return Result.success(authTokens);
    } catch (e) {
      _logger.error('Login error', error: e);

      // Handle different types of exceptions from the ApiClient
      if (e is InvalidCredentialsException) {
        // HTTP 401 - Invalid credentials
        return Result.failure(e);
      } else if (e is ValidationException) {
        // HTTP 400 - Bad request/validation error
        return Result.failure(AuthenticationException(
          'Invalid login data: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is ServerException) {
        // HTTP 500 - Server error
        return Result.failure(AuthenticationException(
          'Server error during login: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is NetworkException) {
        // Network connectivity issues
        return Result.failure(AuthenticationException(
          'Network error during login: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is AuthenticationException) {
        // Other authentication exceptions
        return Result.failure(e);
      }

      // Fallback for any unexpected errors
      return Result.failure(AuthenticationException(
        'Login failed: ${e.toString()}',
        code: 'unknown_error',
      ));
    }
  }

  @override
  Future<Result<AuthTokens, AuthenticationException>> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) async {
    try {
      final authTokens = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profilePhotoUrl: profilePhotoUrl,
      );
      return Result.success(authTokens);
    } catch (e) {
      _logger.error('Registration error', error: e);

      // Handle different types of exceptions from the ApiClient
      if (e is ValidationException) {
        // HTTP 400 - Bad request/validation error
        return Result.failure(AuthenticationException(
          'Invalid registration data: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is ServerException) {
        // HTTP 500 - Server error
        return Result.failure(AuthenticationException(
          'Server error during registration: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is NetworkException) {
        // Network connectivity issues
        return Result.failure(AuthenticationException(
          'Network error during registration: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is AuthenticationException) {
        // Other authentication exceptions
        return Result.failure(e);
      } else if (e is DomainException) {
        // Handle other domain exceptions
        return Result.failure(AuthenticationException(e.message,
            code: e.code, requestId: e.requestId));
      }

      // Fallback for any unexpected errors
      return Result.failure(AuthenticationException(
        'Registration failed: ${e.toString()}',
        code: 'unknown_error',
      ));
    }
  }

  @override
  Future<Result<bool, AuthenticationException>> logout() async {
    try {
      await _authService.logout();
      return Result.success(true);
    } catch (e) {
      _logger.error('Logout error', error: e);

      // Handle different types of exceptions from the ApiClient
      if (e is AuthorizationException) {
        // HTTP 403 - Forbidden
        return Result.failure(AuthenticationException(
          'Not authorized to logout: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is ServerException) {
        // HTTP 500 - Server error
        return Result.failure(AuthenticationException(
          'Server error during logout: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is NetworkException) {
        // Network connectivity issues
        return Result.failure(AuthenticationException(
          'Network error during logout: ${e.message}',
          code: e.code,
          requestId: e.requestId,
        ));
      } else if (e is AuthenticationException) {
        // Other authentication exceptions
        return Result.failure(e);
      } else if (e is DomainException) {
        // Handle other domain exceptions
        return Result.failure(AuthenticationException(e.message,
            code: e.code, requestId: e.requestId));
      }

      // Fallback for any unexpected errors
      return Result.failure(AuthenticationException(
        'Logout failed: ${e.toString()}',
        code: 'unknown_error',
      ));
    }
  }
}
