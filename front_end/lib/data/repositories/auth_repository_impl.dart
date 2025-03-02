import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  final AppLogger _logger = AppLogger();
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthRepositoryImpl({
    required http.Client client,
    required FlutterSecureStorage storage,
  })  : _client = client,
        _secureStorage = storage;

  @override
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

      _logger.debug('Response status: ${response.statusCode}');
      _logger.debug('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.debug('Login successful. Response data: $data');

        // Save both access and refresh tokens
        if (data['access'] != null) {
          _logger.debug('Saving access token');
          await saveAccessToken(data['access']);
        } else {
          _logger.warning('No access token in response');
        }

        if (data['refresh'] != null) {
          _logger.debug('Saving refresh token');
          await saveRefreshToken(data['refresh']);
        } else {
          _logger.warning('No refresh token in response');
        }

        // Create user from response data
        final user = UserModel.fromJson(data);
        _logger.debug('Created user model: ${user.email}');
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
        _logger.error('Could not connect to server. Please check your internet connection.');
        throw Exception(
            'Could not connect to server. Please check your internet connection.');
      }
      _logger.error('Error during login', error: e, stackTrace: stackTrace);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<User> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'password2': password2,
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
          await saveAccessToken(data['access']);
        }
        if (data['refresh'] != null) {
          await saveRefreshToken(data['refresh']);
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
        _logger.error('Could not connect to server. Please check your internet connection.');
        throw Exception(
            'Could not connect to server. Please check your internet connection.');
      }
      _logger.error('Error during registration', error: e, stackTrace: stackTrace);
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Attempt to invalidate the refresh token on the server
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        await _client.post(
          Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.logoutEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refresh_token': refreshToken}),
        );
      }

      // Always clear local tokens
      await Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
      ]);
      _logger.debug('Successfully cleared all tokens');
    } catch (e, stackTrace) {
      _logger.error('Error during logout', error: e, stackTrace: stackTrace);
      throw Exception('Failed to logout');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await getAccessToken();
      _logger.debug('Starting token validation check');
      _logger.debug('API URL: ${AppConfig.apiBaseUrl}${AppConfig.profileEndpoint}');

      if (token == null) {
        _logger.debug('No token found in storage');
        return false;
      }

      _logger.debug('Found token, attempting to validate with backend');
      // Try to get user profile to verify token
      final response = await _client.get(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.error('Token validation request timed out');
          throw TimeoutException('Connection to server timed out');
        },
      );

      _logger.debug('Token validation response: ${response.statusCode}');
      _logger.debug('Token validation response body: ${response.body}');

      if (response.statusCode == 200) {
        _logger.debug('Token is valid, user is authenticated');
        return true;
      } else if (response.statusCode == 401) {
        _logger.debug('Token expired, attempting refresh');
        return refreshToken();
      } else {
        _logger.error('Unexpected status code: ${response.statusCode}');
      }

      return false;
    } catch (e, stackTrace) {
      _logger.error('Error during token validation', error: e, stackTrace: stackTrace);
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        _logger.error('Could not connect to server. Is the backend running?');
      }
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        _logger.debug('No refresh token found');
        return false;
      }

      final response = await _client.post(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.refreshTokenEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['access'] != null) {
          _logger.debug('Token refresh successful');
          await saveAccessToken(data['access']);
          
          // If a new refresh token is provided, save it
          if (data['refresh'] != null) {
            await saveRefreshToken(data['refresh']);
          }
          
          return true;
        }
      }

      // If refresh failed, clear tokens
      await Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
      ]);

      _logger.error('Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e, stackTrace) {
      _logger.error('Error refreshing token', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      _logger.debug('Current access token: $token');

      if (token == null) {
        _logger.debug('No access token found');
        return null;
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.debug('Get current user response status: ${response.statusCode}');
      _logger.debug('Get current user response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data);
        _logger.debug('Successfully got current user: ${user.email}');
        return user;
      } else if (response.statusCode == 401) {
        _logger.debug('Token expired or invalid');
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return getCurrentUser();
        }
        await deleteAccessToken();
        return null;
      } else {
        _logger.error('Failed to get user profile: ${response.statusCode}');
        throw Exception('Failed to get user profile');
      }
    } catch (e, stackTrace) {
      _logger.error('Error getting current user', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      _logger.debug(
          'Retrieved access token from secure storage: ${token != null ? 'Token exists' : 'No token'}');
      return token;
    } catch (e, stackTrace) {
      _logger.error('Error reading access token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      _logger.debug(
          'Retrieved refresh token from secure storage: ${token != null ? 'Token exists' : 'No token'}');
      return token;
    } catch (e, stackTrace) {
      _logger.error('Error reading refresh token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      _logger.debug('Access token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('Error saving access token', error: e, stackTrace: stackTrace);
      throw Exception('Failed to save access token');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
      _logger.debug('Refresh token saved successfully');
    } catch (e, stackTrace) {
      _logger.error('Error saving refresh token', error: e, stackTrace: stackTrace);
      throw Exception('Failed to save refresh token');
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      _logger.debug('Access token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('Error deleting access token', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
      _logger.debug('Refresh token deleted successfully');
    } catch (e, stackTrace) {
      _logger.error('Error deleting refresh token', error: e, stackTrace: stackTrace);
    }
  }
}
