export 'package:semo/core/domain/entities/user_entity.dart';

/// Domain entity representing authentication tokens
/// 
/// This entity matches the backend AuthTokens value object structure
/// and contains all the necessary information for authentication
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String firstName;
  final String? lastName;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.firstName,
    this.lastName,
  });
}
