import 'package:semo/core/domain/entities/user_entity.dart';
import 'package:semo/core/utils/result.dart';
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
    return await _tokenService.getAccessToken() != null;
  }

  /// get refresh token
  Future<bool> getRefreshToken() async {
    return await _tokenService.getRefreshToken() != null;
  }

  /// refresh token
  Future<bool> refreshToken() async {
    return await _tokenService.refreshToken();
  }

  /// clear all tokens
  Future<void> clearAllTokens() async {
    await _tokenService.clearAllTokens();
  }

  /// Retrieves the current user's profile information
  Future<Result<User, BasicProfileException>> getCurrentUser() {
    return _basicProfileRepository.getCurrentUser();
  }
}
