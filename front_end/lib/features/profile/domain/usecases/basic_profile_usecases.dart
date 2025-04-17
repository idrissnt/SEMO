import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:semo/features/profile/domain/repositories/services/basic_profile_repository.dart';

/// Use cases for basic profile operations
class BasicProfileUseCases {
  final BasicProfileRepository _profileRepository;

  /// Constructor
  BasicProfileUseCases({
    required BasicProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  /// Get the current user's profile
  Future<Result<User, BasicProfileException>> getCurrentUser() async {
    return await _profileRepository.getCurrentUser();
  }

  /// Update the user's profile
  Future<Result<User, BasicProfileException>> updateUserProfile({
    required String firstName,
    // String? email,
    String? lastName,
    String? profilePhotoUrl,
    String? phoneNumber,
  }) async {
    return await _profileRepository.updateUserProfile(
      firstName: firstName,
      // email: email,
      lastName: lastName,
      profilePhotoUrl: profilePhotoUrl,
      phoneNumber: phoneNumber,
    );
  }

  /// Delete the user's account
  Future<Result<bool, BasicProfileException>> deleteAccount() async {
    return await _profileRepository.deleteAccount();
  }
}
