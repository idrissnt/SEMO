import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/services/api_client.dart';
import 'package:semo/core/infrastructure/services/token_service.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/infrastructure/interceptors/auth_interceptor.dart';
import 'package:semo/features/auth/di/auth_injection.dart';

// Feature-specific dependency injection
import 'package:semo/features/store/di/store_injection.dart';
import 'package:semo/features/home/di/home_screen_injection.dart';
import 'package:semo/features/profile/di/profile_injection.dart';

/// Service Locator accessible anywhere in the app
final sl = GetIt.instance;

/// Initializes all application dependencies
/// This is the main entry point for dependency injection
Future<void> initializeDependencies() async {
  try {
    // Register dependencies by module
    await _registerCoreServices();
    await _registerNetworkServices();
    await _registerFeatureModules();
  } catch (e, stackTrace) {
    final logger = sl<AppLogger>();
    logger.error('Failed to initialize dependencies', 
        error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Registers core services like logging and secure storage
Future<void> _registerCoreServices() async {
  // Register logger first so it can be used during initialization
  sl.registerLazySingleton<AppLogger>(() => AppLogger());
  
  // Register secure storage for token persistence
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage()
  );
}

/// Registers all network-related services
/// Handles the creation of Dio, API clients, and token services
Future<void> _registerNetworkServices() async {
  // Create a basic Dio instance for TokenService
  final tokenServiceDio = _createBasicDio();
  
  // Register TokenService with its own Dio instance
  sl.registerLazySingleton<TokenService>(
    () => TokenServiceImpl(
      dio: tokenServiceDio,
      storage: sl<FlutterSecureStorage>(),
    ),
  );
  
  // Create and configure the main Dio instance
  final mainDio = _createBasicDio();
  _configureDioInterceptors(mainDio);
  
  // Register the fully configured Dio instance
  sl.registerLazySingleton<Dio>(() => mainDio);
  
  // Register API client
  sl.registerLazySingleton<ApiClient>(() => ApiClientImpl(
    dio: sl<Dio>(),
    logger: sl<AppLogger>(),
  ));
}

/// Registers all feature-specific modules
Future<void> _registerFeatureModules() async {
  registerAuthDependencies();
  registerStoreDependencies();
  registerHomeScreenDependencies();
  registerProfileDependencies();
}

/// Creates a basic Dio instance with default configuration
Dio _createBasicDio() {
  return Dio(BaseOptions(
    baseUrl: ApiRoutes.base,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));
}

/// Configures all interceptors for the main Dio instance
void _configureDioInterceptors(Dio dio) {
  final logger = sl<AppLogger>();
  
  // Add error handling interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onError: (DioException e, handler) {
      // The actual error handling will be done in the ApiClient
      handler.next(e);
    },
  ));
  
  // Create and add auth interceptor
  final authInterceptor = AuthInterceptor(
    tokenService: sl<TokenService>(),
    logger: logger,
  );
  dio.interceptors.add(authInterceptor);
  
  // Register auth interceptor for potential reuse
  sl.registerLazySingleton<AuthInterceptor>(() => authInterceptor);
}
