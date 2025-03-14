import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../domain/entities/user_auth/user.dart';
import '../../../models/user_auth/user_model.dart';
import 'token_service.dart';

/// Handles authentication operations like login, register, and logout
class AuthService {
  final http.Client _client;
  final TokenService _tokenService;
  final AppLogger _logger = AppLogger();

  AuthService({
    required http.Client client,
    required TokenService tokenService,
  })  : _client = client,
        _tokenService = tokenService;

  /// Authenticates a user with email and password
  /// Returns a User object on success
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.debug('Login successful with status ${response.statusCode}');

        // Save both access and refresh tokens
        if (data['access'] != null) {
          _logger.debug('Saving access token');
          await _tokenService.saveAccessToken(data['access']);
        } else {
          _logger.warning('No access token in response');
        }

        if (data['refresh'] != null) {
          _logger.debug('Saving refresh token');
          await _tokenService.saveRefreshToken(data['refresh']);
        } else {
          _logger.warning('No refresh token in response');
        }

        // Create user from response data
        final user = UserModel.fromJson(data);
        return user;
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
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
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      _logger.debug('Register Response status: ${response.statusCode}');
      _logger.debug('Register Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _logger.debug('Register Decoded data: $data');

        // Save both access and refresh tokens if provided
        if (data['access'] != null) {
          await _tokenService.saveAccessToken(data['access']);
        }
        if (data['refresh'] != null) {
          await _tokenService.saveRefreshToken(data['refresh']);
        }

        // Create user from response data
        final user = UserModel.fromJson(data);
        return user;
      } else {
        // More detailed error handling
        final data = json.decode(response.body);
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
      // Attempt to invalidate the token on the server
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        await _client.post(
          Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.logoutEndpoint}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      // Always clear local tokens
      await Future.wait([
        _tokenService.deleteAccessToken(),
        _tokenService.deleteRefreshToken(),
      ]);
      _logger.debug('Successfully cleared all tokens');
    } catch (e, stackTrace) {
      _logger.error('Error during logout', error: e, stackTrace: stackTrace);
      throw Exception('Failed to logout');
    }
  }
}
