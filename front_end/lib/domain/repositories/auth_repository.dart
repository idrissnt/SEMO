import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String password2,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<String?> getAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> deleteAccessToken();

  // New methods for persistent auth
  Future<bool> hasValidToken();
  Future<bool> refreshToken();
}
