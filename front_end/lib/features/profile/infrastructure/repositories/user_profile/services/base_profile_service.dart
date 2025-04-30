import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/profile/infrastructure/models/profile_model.dart';
import 'package:semo/features/profile/domain/entities/profile_entity.dart';

/// Service for handling user profile operations
class BaseProfileService {
  final ApiClient _apiClient;
  final AppLogger _logger;

  BaseProfileService({
    required ApiClient apiClient,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _logger = logger;

  /// Retrieves the current user's profile information
  Future<User> getCurrentUser() async {
    try {
      _logger.debug('Fetching current user profile');

      // The ApiClient automatically handles authentication headers and token refresh
      final data =
          await _apiClient.get<Map<String, dynamic>>(ProfileApiRoutes.me);

      // Convert the response data to a domain entity
      final user = UserModel.fromJson(data).toEntity();
      _logger.debug('Successfully retrieved user profile');

      return user;
    } catch (e) {
      _logger.error('Failed to get user profile', error: e);
      rethrow;
    }
  }

  /// Updates the user's profile information
  Future<User> updateUserProfile({
    required String firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) async {
    try {
      _logger.debug('Updating user profile');

      // Prepare request data
      final requestData = {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'profile_photo_url': profilePhotoUrl,
      };

      // Remove null values
      requestData.removeWhere((key, value) => value == null);

      // The ApiClient automatically handles authentication headers and token refresh
      final data = await _apiClient.patch<Map<String, dynamic>>(
        ProfileApiRoutes.updateProfile,
        data: requestData,
      );

      // Convert the response data to a domain entity
      final user = UserModel.fromJson(data).toEntity();
      _logger.debug('Successfully updated user profile');

      return user;
    } catch (e) {
      _logger.error('Failed to update user profile', error: e);
      rethrow;
    }
  }

  /// Delete the user's account
  Future<bool> deleteAccount() async {
    try {
      _logger.debug('Deleting account');

      // The ApiClient automatically handles authentication headers and token refresh
      await _apiClient.delete<void>(
        ProfileApiRoutes.deleteAccount,
      );

      _logger.debug('Successfully deleted user account');
      return true;
    } catch (e) {
      _logger.error('Failed to delete account', error: e);
      rethrow;
    }
  }
}
