// ignore_for_file: avoid_print

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/logger.dart';

class AuthService {
  final FlutterSecureStorage storage;
  final AppLogger _logger = AppLogger();

  AuthService({required this.storage});

  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: 'access_token');
    } catch (e) {
      _logger.error('Error retrieving access token', error: e);
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: 'refresh_token');
    } catch (e) {
      _logger.error('Error retrieving refresh token', error: e);
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    try {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
      _logger.info('Tokens cleared successfully');
    } catch (e) {
      _logger.error('Error clearing tokens', error: e);
    }
  }
}
