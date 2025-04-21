class AppConfig {
  // Environment is set via --dart-define=ENVIRONMENT=dev|staging|prod
  static final Environment environment = _getEnvironment();

  // Base URLs - the main environment-specific config
  static String get baseUrl {
    switch (environment) {
      case Environment.dev:

        // Update with the Mac's current IP address on the local network actually used
        return 'http://192.168.172.184:8000'; // Current Mac IP address
      case Environment.staging:
        return 'https://staging-api.semo.com';
      case Environment.prod:
        return 'https://api.semo.com';
    }
  }

  // Media URL
  static String get mediaBaseUrl => '$baseUrl/media';

  // App metadata
  static const String appName = 'SEMO';
  static const String appVersion = '1.0.0';
}

enum Environment { dev, staging, prod }

// Helper function to get environment from dart-define
Environment _getEnvironment() {
  const envName = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
  switch (envName) {
    case 'prod':
      return Environment.prod;
    case 'staging':
      return Environment.staging;
    case 'dev':
    default:
      return Environment.dev;
  }
}
