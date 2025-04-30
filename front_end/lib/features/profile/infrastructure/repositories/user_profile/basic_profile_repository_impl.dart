import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/utils/result.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/repositories/user_profile/basic_profile_repository.dart';
import 'package:semo/features/profile/domain/exceptions/profile/profile_exceptions.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_profile/services/base_profile_service.dart';

/// Implementation of the BasicProfileRepository interface that delegates to specialized services
class BasicProfileRepositoryImpl implements BasicProfileRepository {
  final BaseProfileService _profileService;
  final AppLogger _logger;

  BasicProfileRepositoryImpl({
    required ApiClient apiClient,
    required AppLogger logger,
  })  : _logger = logger,
        _profileService = BaseProfileService(
          apiClient: apiClient,
          logger: logger,
        );

  @override
  Future<Result<User, BasicProfileException>> getCurrentUser() async {
    try {
      final user = await _profileService.getCurrentUser();
      return Result.success(user);
    } catch (e, stackTrace) {
      _logger.error('Error getting current user',
          error: e, stackTrace: stackTrace);
      return Result.failure(BasicProfileException(e.toString()));
    }
  }

  @override
  Future<Result<User, BasicProfileException>> updateUserProfile({
    required String firstName,
    String? lastName,
    String? profilePhotoUrl,
    String? phoneNumber,
  }) async {
    try {
      final user = await _profileService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        profilePhotoUrl: profilePhotoUrl,
        phoneNumber: phoneNumber,
      );
      return Result.success(user);
    } catch (e, stackTrace) {
      _logger.error('Error updating user profile',
          error: e, stackTrace: stackTrace);
      return Result.failure(BasicProfileException(e.toString()));
    }
  }

  @override
  Future<Result<bool, BasicProfileException>> deleteAccount() async {
    try {
      final success = await _profileService.deleteAccount();
      return Result.success(success);
    } catch (e, stackTrace) {
      _logger.error('Error deleting account', error: e, stackTrace: stackTrace);
      return Result.failure(BasicProfileException(e.toString()));
    }
  }
}
