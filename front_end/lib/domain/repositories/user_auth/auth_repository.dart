import '../../entities/user_auth/user.dart';

/// AuthRepository defines the contract for authentication operations
abstract class AuthRepository {
  /// Authenticates a user with email and password
  /// Returns a User object on success
  Future<User> login({
    required String email,
    required String password,
  });

  /// Registers a new user with the provided information
  /// Returns the created User object on success
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  /// Logs out the current user and invalidates their tokens
  Future<void> logout();

  /// Retrieves the currently authenticated user
  /// Returns null if no user is authenticated
  Future<User?> getCurrentUser();

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
