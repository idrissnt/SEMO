/// Domain service interface for token management
///
/// This interface defines the contract for token-related operations
/// following clean architecture principles. It focuses on the business rules
/// related to authentication tokens.
abstract class TokenService {
  /// Retrieves the current access token
  Future<String?> getAccessToken();
  
  /// Retrieves the current refresh token
  Future<String?> getRefreshToken();
  
  /// Saves the access token
  Future<void> saveAccessToken(String token);
  
  /// Saves the refresh token
  Future<void> saveRefreshToken(String token);
  
  /// Deletes the access token
  Future<void> deleteAccessToken();
  
  /// Deletes the refresh token
  Future<void> deleteRefreshToken();
  
  /// Checks if the current token is valid
  /// Returns true if a valid token exists, false otherwise
  Future<bool> hasValidToken();
  
  /// Attempts to refresh the token
  /// Returns true if refresh was successful, false otherwise
  Future<bool> refreshToken();
  
  /// Clears all tokens (both access and refresh)
  Future<void> clearAllTokens();
}
