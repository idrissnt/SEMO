import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/interceptors/auth_interceptor.dart';
import 'package:semo/core/infrastructure/services/api_client.dart';
import 'package:semo/core/utils/logger.dart';

/// Dependency injection module for network services
///
/// This module registers all network-related dependencies in the GetIt service locator.
/// It follows clean architecture principles by registering interfaces from the domain layer
/// and their implementations from the infrastructure layer.
///
/// This module is responsible for:
/// 1. Configuring Dio instances with appropriate interceptors
/// 2. Registering API clients
/// 3. Registering the AuthInterceptor
class NetworkServiceModule {
  /// Registers all network-related dependencies
  static void register(GetIt getIt) {
    // Get the main Dio instance (already registered by DioModule)
    final mainDio = getIt<Dio>();

    // Configure the Dio interceptors
    _configureDioInterceptors(getIt, mainDio);

    // Register API client
    getIt.registerLazySingleton<ApiClient>(() => ApiClientImpl(
          dio: getIt<Dio>(), // main Dio instance
          logger: getIt<AppLogger>(),
        ));
  }

  /// Configures all interceptors for the main Dio instance
  static void _configureDioInterceptors(GetIt getIt, Dio dio) {
    // Add error handling interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        // The actual error handling will be done in the ApiClient
        handler.next(e);
      },
    ));
    
    // Register AuthInterceptor
    getIt.registerFactory<AuthInterceptor>(() => AuthInterceptor(
          tokenService: getIt<TokenService>(),
          logger: getIt<AppLogger>(),
        ));

    // Add the auth interceptor to the main Dio instance
    if (!dio.interceptors.any((i) => i is AuthInterceptor)) {
      dio.interceptors.add(getIt<AuthInterceptor>());
    }
  }
}
