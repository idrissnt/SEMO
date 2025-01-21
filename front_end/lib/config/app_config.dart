import 'package:flutter/foundation.dart';

class AppConfig {
  static const bool isProduction = !kDebugMode;

  // API Configuration
  static const String baseUrl = isProduction
      ? 'https://yourdomain.com/api/auth' // Replace with your production URL
      : 'http://172.20.10.10:8000/api/auth'; // url local windows. help to connect phisical device
  // : 'http://10.0.2.2:8000/api/auth'; // url emulator android

  // Logging Configuration
  static const bool enableLogging = !isProduction;

  // Performance and Error Tracking
  static const bool enablePerformanceTracking = isProduction;

  // Feature Flags
  static const Map<String, bool> featureFlags = {
    'analytics': isProduction,
    'crashReporting': isProduction,
    'debugTools': !isProduction,
  };
}
