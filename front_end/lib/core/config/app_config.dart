class AppConfig {
  static const String apiBaseUrl =
      'http://172.20.10.5:8000/api/v1'; // idriss NN For every device
  // 'http://192.168.187.184:8000/api/v1'; // coco NN For every device

  // Base URL for media files (images)
  // static const String mediaBaseUrl = 'http://172.20.10.5:8000';
  static const String mediaBaseUrl = 'http://172.20.10.5:8000';

  static const int apiTimeout = 30000; // milliseconds

  // API Endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String registerEndpoint = '/auth/register/';
  static const String profileEndpoint = '/auth/profile/';
  static const String refreshTokenEndpoint = '/auth/refresh/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String allStores = '/stores/';
  static const String storesFullDetails = '/stores/full_details/';

  // App settings
  static const String appName = 'SEMO';
  static const String appVersion = '1.0.0';

  // Cache settings
  static const int maxCacheAge = 3600; // seconds
  static const int maxCacheSize = 10 * 1024 * 1024; // 10MB

  // Pagination
  static const int defaultPageSize = 20;
}
