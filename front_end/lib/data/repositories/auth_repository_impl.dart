import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'access_token';

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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login successful. Response data: $data');

        // Save both access and refresh tokens
        if (data['access'] != null) {
          print('Saving access token');
          await saveAccessToken(data['access']);
        } else {
          print('Warning: No access token in response');
        }

        if (data['refresh'] != null) {
          print('Saving refresh token');
          await _secureStorage.write(
              key: 'refresh_token', value: data['refresh']);
        } else {
          print('Warning: No refresh token in response');
        }

        // Create user from response data
        final user = UserModel.fromJson(data);
        print('Created user model: ${user.email}');
        return user;
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        final errorMessage = data['detail'] ??
            data['message'] ??
            data['error'] ??
            'Invalid credentials';
        throw Exception(errorMessage);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
            'Could not connect to server. Please check your internet connection.');
      }
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

      print('Register Response status: ${response.statusCode}');
      print('Register Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Register Decoded data: $data');

        // Save both access and refresh tokens if provided
        if (data['access'] != null) {
          await saveAccessToken(data['access']);
        }
        if (data['refresh'] != null) {
          await _secureStorage.write(
              key: 'refresh_token', value: data['refresh']);
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

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
            'Could not connect to server. Please check your internet connection.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('Starting logout process');
      final token = await getAccessToken();
      
      if (token != null) {
        try {
          // Attempt server-side logout
          final response = await _client.post(
            Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.logoutEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Logout request timed out');
              throw TimeoutException('Connection to server timed out');
            },
          );

          print('Server logout response: ${response.statusCode}');
          if (response.statusCode != 200) {
            print('Server logout failed: ${response.body}');
          }
        } catch (e) {
          // Log but continue with local logout
          print('Server logout failed, continuing with local logout: $e');
        }
      }

      // Always clear local tokens
      await Future.wait([
        deleteAccessToken(),
        _secureStorage.delete(key: 'refresh_token'),
      ]);
      print('Successfully cleared all tokens');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await getAccessToken();
      print('Starting token validation check');
      print('API URL: ${AppConfig.apiBaseUrl}${AppConfig.profileEndpoint}');

      if (token == null) {
        print('No token found in storage');
        return false;
      }

      print('Found token, attempting to validate with backend');
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
          print('Token validation request timed out');
          throw TimeoutException('Connection to server timed out');
        },
      );

      print('Token validation response: ${response.statusCode}');
      print('Token validation response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Token is valid, user is authenticated');
        return true;
      } else if (response.statusCode == 401) {
        print('Token expired, attempting refresh');
        return refreshToken();
      } else {
        print('Unexpected status code: ${response.statusCode}');
      }

      return false;
    } catch (e) {
      print('Error during token validation: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        print('Could not connect to server. Is the backend running?');
      }
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        print('No refresh token found');
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
          print('Token refresh successful');
          await saveAccessToken(data['access']);
          return true;
        }
      }

      // If refresh failed, clear tokens
      await Future.wait([
        deleteAccessToken(),
        _secureStorage.delete(key: 'refresh_token'),
      ]);

      print('Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      print('Current access token: $token');

      if (token == null) {
        print('No access token found');
        return null;
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get current user response status: ${response.statusCode}');
      print('Get current user response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data);
        print('Successfully got current user: ${user.email}');
        return user;
      } else if (response.statusCode == 401) {
        print('Token expired or invalid');
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry the request with new token
          return getCurrentUser();
        }
        await deleteAccessToken();
        return null;
      } else {
        print('Failed to get user profile: ${response.statusCode}');
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      print(
          'Retrieved access token from secure storage: ${token != null ? 'Token exists' : 'No token'}');
      return token;
    } catch (e) {
      print('Error reading access token: $e');
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      print('Access token saved successfully');
    } catch (e) {
      print('Error saving access token: $e');
      throw Exception('Failed to save access token');
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      print('Access token deleted successfully');
    } catch (e) {
      print('Error deleting access token: $e');
    }
  }
}
