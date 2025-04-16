import 'package:semo/core/domain/entities/user_entity.dart';
import 'package:semo/features/profile/domain/repositories/services/basic_profile_repository.dart';

class UserProfileUseCase {
  final BasicProfileRepository _basicProfileRepository;

  UserProfileUseCase({
    required BasicProfileRepository basicProfileRepository,
  }) : _basicProfileRepository = basicProfileRepository;

  /// Retrieves the current user's profile information
  Future<User> getCurrentUser() {
    return _basicProfileRepository.getCurrentUser();
  }
}
