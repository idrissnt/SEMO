// No need for these imports as we're using dependency injection

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';

import 'package:semo/core/domain/exceptions/api_exceptions.dart';
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
      // The service layer handles API communication and maps API exceptions to domain exceptions
      _logger.debug('Sending login request for user: $email');
      final authTokens =
          await _authService.login(email: email, password: password);

      _logger.debug('Backend Login successful');

      return Result.success(authTokens);
    } catch (e) {
      // Log the error once at the repository level
      _logger.error('Backend Login error',
          error: e is DomainException ? e.message : e.toString());

      // Map domain exceptions to Result.failure with appropriate types
      if (e is AuthenticationException) {
        // Domain exceptions can be directly returned
        return Result.failure(e);
      } else if (e is DomainException) {
        // Handle other domain exceptions
        return Result.failure(AuthenticationException(
          e.message,
          code: e.code,
          requestId: e.requestId,
        ));
      } else {
        // Fallback for unexpected exceptions
        return Result.failure(AuthenticationException(
          'Unexpected error during login: ${e.toString()}',
        ));
      }
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
      _logger.debug('Sending registration request for user: $email');
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
      // Log the error once at the repository level
      _logger.error('Registration error',
          error: e is DomainException ? e.message : e.toString());

      // Map domain exceptions to Result.failure with appropriate types
      if (e is AuthenticationException) {
        // Domain exceptions can be directly returned
        return Result.failure(e);
      } else if (e is DomainException) {
        // Handle other domain exceptions
        return Result.failure(AuthenticationException(
          e.message,
          code: e.code,
          requestId: e.requestId,
        ));
      } else {
        // Fallback for unexpected exceptions
        return Result.failure(AuthenticationException(
          'Registration failed: ${e.toString()}',
        ));
      }
    }
  }

  @override
  Future<Result<bool, AuthenticationException>> logout() async {
    try {
      _logger.debug('Sending logout request');
      await _authService.logout();
      return Result.success(true);
    } catch (e) {
      // Log the error once at the repository level
      _logger.error('Logout error',
          error: e is DomainException ? e.message : e.toString());

      // Map domain exceptions to Result.failure with appropriate types
      if (e is AuthenticationException) {
        // Domain exceptions can be directly returned
        return Result.failure(e);
      } else if (e is DomainException) {
        // Handle other domain exceptions
        return Result.failure(AuthenticationException(
          e.message,
          code: e.code,
          requestId: e.requestId,
        ));
      } else {
        // Fallback for unexpected exceptions
        return Result.failure(AuthenticationException(
          'Logout failed: ${e.toString()}',
        ));
      }
    }
  }
}
