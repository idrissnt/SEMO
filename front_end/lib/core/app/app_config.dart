class AppConfig {
  // Environment is set via --dart-define=ENVIRONMENT=dev|staging|prod
  static final Environment environment = _getEnvironment();

  // Base URLs - the main environment-specific config
  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://172.20.10.5:8000'; // idriss NN For every device
      // return 'http://192.168.187.184:8000'; // coco NN For every device
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
