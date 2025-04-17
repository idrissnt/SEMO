/// TokenService defines the contract for token operations
abstract class TokenService {
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
