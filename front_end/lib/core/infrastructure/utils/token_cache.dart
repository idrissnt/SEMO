/// In-memory cache for authentication tokens
///
/// This class provides a simple in-memory cache for tokens to reduce
/// the number of secure storage operations, which can be slow.
class TokenCache {
  /// The cached access token
  String? accessToken;

  /// The cached refresh token
  String? refreshToken;

  /// The expiry date of the access token
  DateTime? accessTokenExpiry;

  /// Clears all cached tokens and related data
  void clear() {
    accessToken = null;
    refreshToken = null;
    accessTokenExpiry = null;
  }

  /// Checks if the access token is cached
  bool hasAccessToken() => accessToken != null;

  /// Checks if the refresh token is cached
  bool hasRefreshToken() => refreshToken != null;

  /// Checks if the token expiry is cached
  bool hasTokenExpiry() => accessTokenExpiry != null;
}
