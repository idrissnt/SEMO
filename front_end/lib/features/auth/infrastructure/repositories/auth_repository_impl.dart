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

      _logger.debug('Backend successful Login user with email: $email');

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
      _logger.debug('Sending registration request for user: $email');
      final authTokens = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profilePhotoUrl: profilePhotoUrl,
      );
      _logger.debug('Backend successful Registration user with email: $email');
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
      _logger.debug('Sending logout request for user: $email');
      await _authService.logout();
      _logger.debug('Backend successful Logout user with email: $email');
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
    // Log the error once at the repository level
    _logger.error('$operation error',
        error: e is DomainException ? e.message : e.toString());

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
      return Result.failure(GenericDomainException(
        '$operation failed: ${e.toString()}',
      ));
    }
  }
}
