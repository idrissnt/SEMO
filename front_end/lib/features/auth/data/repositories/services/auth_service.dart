import 'package:dio/dio.dart';
import 'package:semo/core/config/app_config.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/data/models/auth_model.dart';
import 'package:semo/features/auth/domain/entities/auth_entity.dart';
import 'package:semo/core/services/token_service.dart';

/// Handles authentication operations like login, register, and logout
class AuthService {
  final Dio _dio;
  final TokenService _tokenService;
  final AppLogger _logger = AppLogger();

  AuthService({
    required Dio dio,
    required TokenService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  /// Authenticates a user with email and password
  /// Returns a User object on success
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}${AppConfig.loginEndpoint}',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.debug('Login successful with status ${response.statusCode}');

        // Save both access and refresh tokens
        if (data['access_token'] != null) {
          _logger.debug('Saving access token');
          await _tokenService.saveAccessToken(data['access_token']);
        } else {
          _logger.warning('No access token in response');
        }

        if (data['refresh_token'] != null) {
          _logger.debug('Saving refresh token');
          await _tokenService.saveRefreshToken(data['refresh_token']);
        } else {
          _logger.warning('No refresh token in response');
        }

        // Create user from response data
        final user = UserModel.fromJson(data['user']).toEntity();
        return user;
      } else if (response.statusCode == 400) {
        final data = response.data;
        final errorMessage = data['detail'] ??
            data['message'] ??
            data['error'] ??
            'Invalid credentials';
        _logger.error('Login failed', error: errorMessage);
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        _logger.error('Invalid credentials');
        throw Exception('Invalid credentials');
      } else {
        _logger.error('Server error: ${response.statusCode}');
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('Connection refused')) {
        _logger.error(
            'Could not connect to server. Please check your internet connection.');
        throw Exception(
            'Could not connect to server. Please check your internet connection.');
      }
      _logger.error('Error during login', error: e, stackTrace: stackTrace);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Registers a new user with the provided information
  /// Returns the created User object on success
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String? lastName,
    required String? phoneNumber,
    required String? profilePhotoUrl,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.apiBaseUrl}${AppConfig.registerEndpoint}',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'profile_photo_url': profilePhotoUrl,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      _logger.debug('Register Response status: ${response.statusCode}');
      _logger.debug('Register Response data: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data;
        _logger.debug('Register Decoded data: $data');

        // Save both access and refresh tokens if provided
        if (data['access_token'] != null) {
          await _tokenService.saveAccessToken(data['access_token']);
        }
        if (data['refresh_token'] != null) {
          await _tokenService.saveRefreshToken(data['refresh_token']);
        }

        // Create user from response data
        final user = UserModel.fromJson(data['user']).toEntity();
        return user;
      } else {
        // More detailed error handling
        final data = response.data;
        String errorMessage = 'Registration failed';

        // Check for specific field errors
        if (data is Map) {
          final fieldErrors = <String>[];
          data.forEach((key, value) {
            if (value is List) {
              fieldErrors.add('$key: ${value.join(', ')}');
            } else if (value is String) {
              fieldErrors.add('$key: $value');
            }
          });

          if (fieldErrors.isNotEmpty) {
            errorMessage = fieldErrors.join('\n');
          } else if (data['detail'] != null) {
            errorMessage = data['detail'];
          } else if (data['message'] != null) {
            errorMessage = data['message'];
          }
        }

        _logger.error('Registration failed', error: errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('Connection refused')) {
        _logger.error(
            'Could not connect to server. Please check your internet connection.');
        throw Exception(
            'Could not connect to server. Please check your internet connection.');
      }
      _logger.error('Error during registration',
          error: e, stackTrace: stackTrace);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Logs out the current user and invalidates their tokens
  Future<void> logout() async {
    try {
      // Get both access and refresh tokens
      final accessToken = await _tokenService.getAccessToken();
      final refreshToken = await _tokenService.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        // Send the refresh token in the request body as required by the backend
        // The user ID will be extracted from the access token on the backend
        await _dio.post(
          '${AppConfig.apiBaseUrl}${AppConfig.logoutEndpoint}',
          data: {
            'refresh_token': refreshToken,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          }),
        );
        _logger.debug('Logout request sent successfully');
      } else {
        _logger
            .warning('Missing tokens for logout, clearing local storage only');
      }

      // Always clear local tokens
      await Future.wait([
        _tokenService.deleteAccessToken(),
        _tokenService.deleteRefreshToken(),
      ]);
      _logger.debug('Successfully cleared all tokens');
    } catch (e, stackTrace) {
      _logger.error('Error during logout', error: e, stackTrace: stackTrace);
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }
}
