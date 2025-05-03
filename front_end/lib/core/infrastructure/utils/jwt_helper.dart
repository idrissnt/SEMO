import 'dart:convert';

/// Helper class for JWT token operations
class JwtHelper {
  /// Extracts the expiry date from a JWT token
  static DateTime? extractExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payload = json.decode(decoded) as Map<String, dynamic>;
        
        if (payload.containsKey('exp')) {
          final expiryTimestamp = payload['exp'] as int;
          return DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
        }
      }
      return null;
    } catch (e) {
      // If parsing fails, return null
      return null;
    }
  }
  
  /// Extracts user ID from a JWT token
  static String? extractUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final normalized = base64Url.normalize(parts[1]);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payload = json.decode(decoded) as Map<String, dynamic>;
        
        // Check different common field names for user ID
        return payload['user_id'] ?? payload['sub'] ?? payload['id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Checks if a token is expired based on its expiry date
  static bool isExpired(DateTime expiryDate) {
    final now = DateTime.now();
    return expiryDate.isBefore(now);
  }
  
  /// Checks if a token is about to expire within the specified duration
  static bool isAboutToExpire(DateTime expiryDate, {Duration threshold = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final expiresIn = expiryDate.difference(now);
    return expiresIn <= threshold;
  }
}
