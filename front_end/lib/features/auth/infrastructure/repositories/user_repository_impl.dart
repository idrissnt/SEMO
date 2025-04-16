import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/features/auth/infrastructure/repositories/services/user_service.dart';
import 'package:semo/features/auth/infrastructure/repositories/services/auth_service.dart';
import 'package:semo/core/infrastructure/services/token_service.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/core/utils/logger.dart';

/// Implementation of the AuthRepository interface that delegates to specialized services
class UserAuthRepositoryImpl implements UserAuthRepository {
  late final TokenService _tokenService;
  late final AuthService _authService;
  late final UserService _userService;
  final _logger = AppLogger();
  UserAuthRepositoryImpl({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) {
    // Create a single instance of TokenService to be shared
    _tokenService = TokenService(
      dio: dio,
      storage: secureStorage,
    );

    // Use the shared TokenService instance
    _authService = AuthService(
      dio: dio,
      tokenService: _tokenService,
    );

    _userService = UserService(
      dio: dio,
      tokenService: _tokenService,
    );
  }

  @override
  Future<Result<User, DomainException>> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.debug('Sending user : $email to the dedicated service');
      final user = await _authService.login(email: email, password: password);
      return Result.success(user);
    } catch (e) {
      return Result.failure(AuthenticationException(e.toString()));
    }
  }

  @override
  Future<Result<User, DomainException>> register({
    required String email,
    required String password,
    required String firstName,
    required String? lastName,
    required String? phoneNumber,
    required String? profilePhotoUrl,
  }) async {
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profilePhotoUrl: profilePhotoUrl,
      );
      return Result.success(user);
    } catch (e) {
      return Result.failure(AuthenticationException(e.toString()));
    }
  }

  @override
  Future<Result<User, DomainException>> getCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(UserProfileException(e.toString()));
    }
  }

  @override
  Future<Result<bool, DomainException>> logout() async {
    try {
      await _authService.logout();
      return Result.success(true);
    } catch (e) {
      return Result.failure(AuthenticationException(e.toString()));
    }
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
}
