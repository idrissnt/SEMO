// This file contains configuration settings for the app api.

class AppConfig {
  static const String apiBaseUrl =
      // 'http://172.20.10.5:8000/api/v1'; // idriss NN For every device
      'http://192.168.187.184:8000/api/v1'; // coco NN For every device

  // Base URL for media files (images)
  // static const String mediaBaseUrl = 'http://172.20.10.5:8000';
  static const String mediaBaseUrl = 'http://192.168.187.184:8000';

  static const int apiTimeout = 30000; // milliseconds

  // Authentication Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String registerEndpoint = '/auth/register/';

  // Token Endpoints
  static const String refreshTokenEndpoint = '/auth/token/refresh/';
  static const String tokenVerifyEndpoint = '/auth/token/verify/';

  // User Endpoints
  static const String profileEndpoint = '/auth/profile/';

  // Store endpoints
  static const String allStores = '/stores/';
  static const String storesFullDetails = '/stores/full_details/';

  // App settings
  static const String appName = 'SEMO';
  static const String appVersion = '1.0.0';

  // Cache settings
  static const int maxCacheAge = 3600; // seconds
  static const int maxCacheSize = 10 * 1024 * 1024; // 10MB
}
