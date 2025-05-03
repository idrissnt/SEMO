import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/infrastructure/di/di_constants.dart';

/// Dependency injection module for Dio HTTP client instances
///
/// This module is responsible for creating and registering all Dio instances
/// used throughout the application. It's separated from other network services
/// to avoid circular dependencies, as both TokenServiceModule and NetworkServiceModule
/// depend on Dio instances.
class DioModule {
  /// Registers all Dio instances
  static void register(GetIt getIt) {
    // Create and register the Dio instance used for token service
    final tokenServiceDio = _createBasicDio();
    getIt.registerLazySingleton<Dio>(
      () => tokenServiceDio,
      instanceName: DIConstants.tokenServiceDio,
    );

    // Create and register the main Dio instance
    // This will be configured with interceptors in NetworkServiceModule
    final mainDio = _createBasicDio();
    getIt.registerLazySingleton<Dio>(() => mainDio);
  }

  /// Creates a basic Dio instance with default configuration
  static Dio _createBasicDio() {
    return Dio(BaseOptions(
      baseUrl: ApiRoutes.base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));
  }
}
