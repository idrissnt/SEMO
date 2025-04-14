import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:semo/core/utils/result.dart';

/// AuthRepository defines the contract for authentication operations
abstract class UserAuthRepository {
  /// Authenticates a user with email and password
  /// Returns a Result containing either a User object on success or an AuthenticationException on failure
  Future<Result<User, DomainException>> login({
    required String email,
    required String password,
  });

  /// Registers a new user with the provided information
  /// Returns a Result containing either the created User object on success or an AuthenticationException on failure
  Future<Result<User, DomainException>> register({
    required String email,
    required String password,
    required String firstName,
    required String? lastName,
    required String? phoneNumber,
    required String? profilePhotoUrl,
  });

  /// Retrieves the currently authenticated user
  /// Returns a Result containing either the User object or a UserProfileException
  /// If no user is authenticated, the Result will contain a UserProfileException
  Future<Result<User, DomainException>> getCurrentUser();

  /// Logs out the current user and invalidates their tokens
  /// Returns a Result indicating success or failure with an error message
  Future<Result<bool, DomainException>> logout();

  /// Retrieves the current access token
  Future<String?> getAccessToken();

  /// Saves the access token to secure storage
  Future<void> saveAccessToken(String token);

  /// Deletes the access token from secure storage
  Future<void> deleteAccessToken();

  /// Checks if the current token is valid
  Future<bool> hasValidToken();

  /// Attempts to refresh the access token using the refresh token
  Future<bool> refreshToken();

  /// Retrieves the current refresh token
  Future<String?> getRefreshToken();

  /// Saves the refresh token to secure storage
  Future<void> saveRefreshToken(String token);

  /// Deletes the refresh token from secure storage
  Future<void> deleteRefreshToken();
}
