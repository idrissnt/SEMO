import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  // Secure Storage Methods
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Shared Preferences Methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return json.decode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Theme Preferences
  static Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  // Onboarding Status
  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? false;
  }
}
