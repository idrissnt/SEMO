import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../domain/entities/user_auth/user.dart';
import '../../../domain/repositories/user_auth/auth_repository.dart';
import 'services/auth_service.dart';
import 'services/token_service.dart';
import 'services/user_service.dart';

/// Implementation of the AuthRepository interface that delegates to specialized services
class AuthRepositoryImpl implements AuthRepository {
  final TokenService _tokenService;
  final AuthService _authService;
  final UserService _userService;

  AuthRepositoryImpl({
    required http.Client client,
    required FlutterSecureStorage secureStorage,
  }) : _tokenService = TokenService(
          client: client,
          storage: secureStorage,
        ),
       _authService = AuthService(
          client: client,
          tokenService: TokenService(
            client: client,
            storage: secureStorage,
          ),
        ),
       _userService = UserService(
          client: client,
          tokenService: TokenService(
            client: client,
            storage: secureStorage,
          ),
        );

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    return _authService.login(email: email, password: password);
  }

  @override
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    return _authService.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    return _authService.logout();
  }

  @override
  Future<bool> hasValidToken() async {
    return _tokenService.hasValidToken();
  }
  
  @override
  Future<bool> refreshToken() async {
    return _tokenService.refreshToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await _userService.getCurrentUser();
    } catch (e) {
      // Return null instead of throwing an exception
      return null;
    }
  }

  @override
  // Token management methods are now delegated to TokenService
  
  @override
  Future<String?> getAccessToken() async {
    return _tokenService.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return _tokenService.getRefreshToken();
  }

  @override
  Future<void> saveAccessToken(String token) async {
    return _tokenService.saveAccessToken(token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    return _tokenService.saveRefreshToken(token);
  }

  @override
  Future<void> deleteAccessToken() async {
    return _tokenService.deleteAccessToken();
  }

  @override
  Future<void> deleteRefreshToken() async {
    return _tokenService.deleteRefreshToken();
  }
  
  // User profile update method
  Future<User> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    return _userService.updateUserProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }
}
