// No need for these imports as we're using dependency injection

import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exception_mapper.dart';

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

  UserAuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenService tokenService,
    required AppLogger logger,
    required AuthExceptionMapper exceptionMapper,
  }) : _authService = AuthService(
          apiClient: apiClient,
          tokenService: tokenService,
          logger: logger,
          exceptionMapper: exceptionMapper,
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
      return _handleAuthError(e, 'Login');
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
      return _handleAuthError(e, 'Registration');
    }
  }

  @override
  Future<Result<bool, AuthenticationException>> logout({
    required String email,
  }) async {
    try {
      await _authService.logout(email);
      return Result.success(true);
    } catch (e) {
      return _handleAuthError(e, 'Logout');
    }
  }

  /// Handles errors from authentication operations and returns appropriate Result objects
  /// @param e The exception that was thrown
  /// @param operation The name of the operation (Login, Registration, Logout)
  /// @returns A Result.failure with the appropriate exception
  Result<T, AuthenticationException> _handleAuthError<T>(
      dynamic e, String operation) {
    // Handle domain-specific exceptions
    if (e is AuthenticationException) {
      // Authentication exceptions can be directly returned
      return Result.failure(e);
    } else if (e is ApiException) {
      // API exceptions can be directly returned as they extend DomainException
      // We need to wrap them in an AuthenticationException to match the return type
      return Result.failure(AuthenticationException(
        '$operation failed: ${e.message}',
        code: e.code,
        requestId: e.requestId,
      ));
    } else {
      // Fallback for unexpected exceptions
      return Result.failure(GenericAuthException(
        '$operation failed: ${e.toString()}',
      ));
    }
  }
}
