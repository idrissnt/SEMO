import 'package:semo/core/config/app_config.dart';
import 'package:semo/core/domain/entities/user_entity.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/core/services/mock/mock_auth_service.dart';
import 'package:semo/features/profile/domain/exceptions/profile/profile_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/user_profile/basic_profile_repository.dart';
import 'package:semo/core/domain/services/token_service.dart';

class UserProfileUseCase {
  final BasicProfileRepository _basicProfileRepository;
  final TokenService _tokenService;

  UserProfileUseCase({
    required BasicProfileRepository basicProfileRepository,
    required TokenService tokenService,
  })  : _basicProfileRepository = basicProfileRepository,
        _tokenService = tokenService;

  /// get access token
  Future<bool> getAccessToken() async {
    // In offline mode, always return true to simulate having a token
    if (AppConfig.useOfflineMode) {
      return true;
    }
    return await _tokenService.getAccessToken() != null;
  }

  /// get refresh token
  Future<bool> getRefreshToken() async {
    // In offline mode, always return true to simulate having a refresh token
    if (AppConfig.useOfflineMode) {
      return true;
    }
    return await _tokenService.getRefreshToken() != null;
  }

  /// refresh token
  Future<bool> refreshToken() async {
    // In offline mode, always return true to simulate successful token refresh
    if (AppConfig.useOfflineMode) {
      return MockAuthService.mockTokenRefresh();
    }
    return await _tokenService.refreshToken();
  }

  /// clear all tokens
  Future<void> clearAllTokens() async {
    await _tokenService.clearAllTokens();
  }

  /// Retrieves the current user's profile information
  Future<Result<User, BasicProfileException>> getCurrentUser() async {
    // In offline mode, return a mock user
    if (AppConfig.useOfflineMode) {
      return MockAuthService.getMockUser();
    }
    return _basicProfileRepository.getCurrentUser();
  }
}
