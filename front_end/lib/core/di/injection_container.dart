import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/services/api_client.dart';
import 'package:semo/core/infrastructure/services/token_service.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';

// Feature-specific dependency injection
import 'package:semo/features/auth/di/auth_injection.dart';
import 'package:semo/features/store/di/store_injection.dart';
import 'package:semo/features/home/di/home_screen_injection.dart';
import 'package:semo/features/profile/di/profile_injection.dart';

// Repositories
import 'package:semo/features/profile/domain/repositories/services/basic_profile_repository.dart';
import 'package:semo/features/profile/domain/repositories/services/user_address_repository.dart';
import 'package:semo/features/profile/infrastructure/repositories/basic_profile_repository_impl.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_address_repository_impl.dart';

final sl = GetIt.instance; // Service Locator accessible anywhere in the app

Future<void> initializeDependencies() async {
  // Core
  sl.registerLazySingleton(() => AppLogger());

  // Exception Mappers - Core implementation
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiRoutes.base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ));

    // Customize error handling to avoid verbose default Dio error messages
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        // Strip the default Dio error message and just pass the error
        // The actual error handling will be done in the ApiClient
        handler.next(e);
      },
    ));

    return dio;
  });
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // API Client - Register interface with implementation
  sl.registerLazySingleton<ApiClient>(() => ApiClientImpl(
        dio: sl(),
        logger: sl(),
      ));

  // Token Service
  sl.registerLazySingleton<TokenService>(
    // Register with interface type
    () => TokenServiceImpl(
      // Provide concrete implementation
      dio: sl(),
      storage: sl(),
    ),
  );

  // Core repositories and services registered here

  sl.registerLazySingleton<BasicProfileRepository>(
    () => BasicProfileRepositoryImpl(
      apiClient: sl(),
      logger: sl(),
    ),
  );

  sl.registerLazySingleton<UserAddressRepository>(
    () => UserAddressRepositoryImpl(
      apiClient: sl(),
      logger: sl(),
    ),
  );

  // Register feature-specific dependencies
  registerAuthDependencies();
  registerStoreDependencies();
  registerHomeScreenDependencies();
  registerProfileDependencies();

  // Add other feature-specific registrations here
}
