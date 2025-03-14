import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../domain/entities/user_auth/user.dart';
import '../../../models/user_auth/user_model.dart';
import 'token_service.dart';

/// Handles user-related operations like getting user profile
class UserService {
  final http.Client _client;
  final TokenService _tokenService;
  final AppLogger _logger = AppLogger();

  UserService({
    required http.Client client,
    required TokenService tokenService,
  })  : _client = client,
        _tokenService = tokenService;

  /// Retrieves the current user's profile information
  Future<User> getCurrentUser() async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data);
        _logger.debug('Successfully got current user: ${user.email}');
        return user;
      } else if (response.statusCode == 401) {
        _logger.debug('Token expired or invalid');
        
        // Try to refresh the token
        final refreshed = await _tokenService.refreshToken();
        if (refreshed) {
          // Retry with new token
          return getCurrentUser();
        } else {
          throw Exception('Authentication failed');
        }
      } else {
        _logger.error('Failed to get user profile: ${response.statusCode}');
        throw Exception('Failed to get user profile');
      }
    } catch (e, stackTrace) {
      _logger.error('Error getting current user',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  /// Updates the user's profile information
  Future<User> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final Map<String, dynamic> updateData = {
        'first_name': firstName,
        'last_name': lastName,
      };
      
      if (email != null) {
        updateData['email'] = email;
      }

      final response = await _client.patch(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data);
        _logger.debug('Successfully updated user profile');
        return user;
      } else if (response.statusCode == 401) {
        _logger.debug('Token expired or invalid');
        
        // Try to refresh the token
        final refreshed = await _tokenService.refreshToken();
        if (refreshed) {
          // Retry with new token
          return updateUserProfile(
            firstName: firstName,
            lastName: lastName,
            email: email,
          );
        } else {
          throw Exception('Authentication failed');
        }
      } else {
        final data = json.decode(response.body);
        final errorMessage = data['detail'] ?? 'Failed to update user profile';
        _logger.error('Failed to update profile: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      _logger.error('Error updating user profile',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}
