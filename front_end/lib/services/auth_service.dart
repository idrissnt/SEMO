import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  final _logger = Logger('AuthService');
  final storage = const FlutterSecureStorage();

  static String get baseUrl {
    // Comprehensive URL selection for different platforms
    if (Platform.isAndroid) {
      return AppConfig.baseUrl;
    } else if (Platform.isIOS) {
      return AppConfig.baseUrl;
    } else if (kIsWeb) {
      return AppConfig.baseUrl;
    } else {
      return AppConfig.baseUrl;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (AppConfig.enableLogging) {
        _logger.info('Starting login process');
        _logger.info('Attempting login for user: $email');
      }

      final url = Uri.parse('$baseUrl/login/');

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.warning('Login request timed out');
          throw TimeoutException(
              'Request timed out. Check your network connection.');
        },
      );

      if (AppConfig.enableLogging) {
        _logger.info(
            'Login response received with status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Securely store tokens
        await storage.write(key: 'access_token', value: data['access']);
        await storage.write(key: 'refresh_token', value: data['refresh']);

        if (AppConfig.enableLogging) {
          _logger.info('Login successful for user: $email');
        }

        return data;
      } else {
        final error = jsonDecode(response.body);
        _logger.warning('Login failed: $error');
        throw Exception(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      _logger.severe('Login error details:');
      _logger.severe('Error type: ${e.runtimeType}');
      _logger.severe('Error message: $e');

      // Comprehensive error logging
      if (e is SocketException) {
        _logger.severe('Socket Exception: Unable to connect to the server');
        _logger.severe('Connection details:');
        _logger.severe('Address: ${e.address}');
        _logger.severe('Port: ${e.port}');
      } else if (e is TimeoutException) {
        _logger.severe('Timeout Exception: Request took too long');
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      if (AppConfig.enableLogging) {
        _logger.info('Starting registration process');
        _logger.info('Sending registration request for user: $email');
      }

      final url = Uri.parse('$baseUrl/register/');
      _logger.info('Attempting registration at URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'password2': password, // Add password confirmation
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (AppConfig.enableLogging) {
        _logger.info(
            'Registration response received with status: ${response.statusCode}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _logger.info('Registration successful');

        // Store tokens if they're included in the response
        if (data['access'] != null) {
          await storage.write(key: 'access_token', value: data['access']);
        }
        if (data['refresh'] != null) {
          await storage.write(key: 'refresh_token', value: data['refresh']);
        }

        if (AppConfig.enableLogging) {
          _logger.info('Registration successful for user: $email');
        }

        return data;
      } else {
        final error = jsonDecode(response.body);
        _logger.warning('Registration failed: $error');
        throw Exception('Registration failed');
      }
    } catch (e) {
      _logger.severe('Registration error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        _logger.warning('No access token found for profile fetch');
        return null;
      }

      final url = Uri.parse('$baseUrl/profile/');
      _logger.info('Fetching user profile from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.warning('Profile fetch request timed out');
          throw Exception('Request timed out. Check your network connection.');
        },
      );

      if (AppConfig.enableLogging) {
        _logger.info(
            'Profile response received with status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (AppConfig.enableLogging) {
          _logger.info('Profile fetched successfully for user');
        }

        return UserModel.fromJson(data);
      } else {
        _logger.warning('Failed to fetch profile: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.severe('Error fetching user profile: $e');
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      if (AppConfig.enableLogging) {
        _logger.info('Retrieving access token from secure storage');
      }

      return await storage.read(key: 'access_token');
    } catch (e) {
      _logger.severe('Error retrieving access token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      if (AppConfig.enableLogging) {
        _logger.info('Retrieving refresh token from secure storage');
      }

      return await storage.read(key: 'refresh_token');
    } catch (e) {
      _logger.severe('Error retrieving refresh token: $e');
      return null;
    }
  }

  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        _logger.warning('No refresh token available');
        return;
      }

      final url = Uri.parse('$baseUrl/token/refresh/');
      _logger.info('Refreshing access token at: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (AppConfig.enableLogging) {
        _logger.info(
            'Refresh response received with status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await storage.write(key: 'access_token', value: data['access']);

        if (AppConfig.enableLogging) {
          _logger.info('Access token refreshed successfully');
        }
      } else {
        _logger.severe('Failed to refresh access token');
        // Clear tokens if refresh fails
        await logout();
      }
    } catch (e) {
      _logger.severe('Error refreshing access token: $e');
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      if (AppConfig.enableLogging) {
        _logger.info('Starting logout process');
      }

      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');

      if (AppConfig.enableLogging) {
        _logger.info('Tokens deleted successfully');
      }
    } catch (e) {
      _logger.severe('Error during logout: $e');
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (AppConfig.enableLogging) {
      _logger.info('Checking authentication status: $token');
    }

    return token != null;
  }
}
