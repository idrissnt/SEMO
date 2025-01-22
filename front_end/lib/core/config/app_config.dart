class AppConfig {
  static const String apiBaseUrl =
      'http://172.20.10.10:8000/api'; // For physical device
  // static const String apiBaseUrl = 'http://localhost:8000/api';  // For iOS Simulator
  static const int apiTimeout = 30000; // milliseconds

  // API Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String profileEndpoint = '/auth/profile/';
  static const String refreshTokenEndpoint = '/auth/token/refresh/';
  static const String logoutEndpoint = '/auth/logout/';  // Added logout endpoint

  // App settings
  static const String appName = 'SEMO';
  static const String appVersion = '1.0.0';

  // Cache settings
  static const int maxCacheAge = 3600; // seconds
  static const int maxCacheSize = 10 * 1024 * 1024; // 10MB

  // Pagination
  static const int defaultPageSize = 20;
}
