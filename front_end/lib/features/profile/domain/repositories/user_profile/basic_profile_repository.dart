import 'package:semo/core/utils/result.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';
import 'package:semo/features/profile/domain/exceptions/profile/profile_exceptions.dart';

/// AuthRepository defines the contract for authentication operations
abstract class BasicProfileRepository {
  /// Retrieves the currently authenticated user
  /// Returns a Result containing either the User object or a BasicProfileException
  /// If no user is authenticated, the Result will contain a BasicProfileException
  Future<Result<User, BasicProfileException>> getCurrentUser();

  /// Returns a Result containing either the updated User object on success or a BasicProfileException on failure
  Future<Result<User, BasicProfileException>> updateUserProfile({
    required String firstName,
    // String? email,
    String? lastName,
    String? profilePhotoUrl,
    String? phoneNumber,
  });

  /// Returns a Result indicating success or failure with a BasicProfileException
  Future<Result<bool, BasicProfileException>> deleteAccount();
}
