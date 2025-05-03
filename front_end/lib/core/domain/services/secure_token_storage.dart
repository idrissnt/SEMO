/// Interface for token storage operations
/// 
/// This interface defines the contract for storing and retrieving authentication tokens
/// following the dependency inversion principle of clean architecture.
abstract class TokenStorage {
  /// Retrieves the access token
  Future<String?> getAccessToken();
  
  /// Retrieves the refresh token
  Future<String?> getRefreshToken();
  
  /// Retrieves the token expiry date
  Future<DateTime?> getTokenExpiry();
  
  /// Saves the access token
  Future<void> saveAccessToken(String token);
  
  /// Saves the refresh token
  Future<void> saveRefreshToken(String token);
  
  /// Saves the token expiry date
  Future<void> saveTokenExpiry(DateTime expiry);
  
  /// Deletes the access token
  Future<void> deleteAccessToken();
  
  /// Deletes the refresh token
  Future<void> deleteRefreshToken();
  
  /// Deletes the token expiry
  Future<void> deleteTokenExpiry();
  
  /// Clears all tokens and related data
  Future<void> clearAllTokens();
}
