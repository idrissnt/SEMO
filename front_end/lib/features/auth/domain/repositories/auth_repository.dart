import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:semo/core/utils/result.dart';

/// AuthRepository defines the contract for authentication operations
abstract class UserAuthRepository {
  /// Authenticates a user with email and password
  /// Returns a Result containing either a User object on success or an AuthenticationException on failure
  Future<Result<AuthTokens, AuthenticationException>> login({
    required String email,
    required String password,
  });

  /// Registers a new user with the provided information
  /// Returns a Result containing either the created User object on success or an AuthenticationException on failure
  Future<Result<AuthTokens, AuthenticationException>> register({
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhotoUrl,
  });

  /// Logs out the current user and invalidates their tokens
  /// Returns a Result indicating success or failure with an error message
  Future<Result<bool, AuthenticationException>> logout();
}
