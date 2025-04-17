import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/infrastructure/models/auth_model.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';

/// Service for handling user profile operations
class UserService {
  final ApiClient _apiClient;
  final AppLogger _logger = AppLogger();

  UserService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

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
        ProfileApiRoutes.me,
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
}
