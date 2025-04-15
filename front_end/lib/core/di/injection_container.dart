import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/infrastructure/api/api_client.dart';
import 'package:semo/core/infrastructure/api/api_routes.dart';

// Feature-specific dependency injection
import 'package:semo/features/store/di/store_injection.dart';
import 'package:semo/features/home/di/home_screen_injection.dart';
import 'package:semo/features/profile/di/profile_injection.dart';

// Repositories
import 'package:semo/features/auth/infrastructure/repositories/user_repository_impl.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';
import 'package:semo/features/profile/domain/repositories/services/basic_profile_repository.dart';
import 'package:semo/features/profile/domain/repositories/services/user_address_repository.dart';
import 'package:semo/features/profile/infrastructure/repositories/basic_profile_repository_impl.dart';
import 'package:semo/features/profile/infrastructure/repositories/user_address_repository_impl.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';
import 'package:semo/features/store/infrastructure/repositories/store_repository_impl.dart';

final sl = GetIt.instance; // Service Locator accessible anywhere in the app

Future<void> initializeDependencies() async {
  // Core
  sl.registerLazySingleton(() => AppLogger());
  sl.registerLazySingleton(() => Dio(BaseOptions(
        baseUrl: ApiRoutes.base,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      )));
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // API Client
  sl.registerLazySingleton(() => ApiClient(
        dio: sl(),
        secureStorage: sl(),
        logger: sl(),
      ));

  // Repositories
  sl.registerLazySingleton<UserAuthRepository>(
    () => UserAuthRepositoryImpl(
      dio: sl(),
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton<BasicProfileRepository>(
    () => BasicProfileRepositoryImpl(
      dio: sl(),
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton<UserAddressRepository>(
    () => UserAddressRepositoryImpl(
      dio: sl(),
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(
      apiClient: sl(),
    ),
  );

  // Register feature-specific dependencies
  registerStoreDependencies();
  registerHomeScreenDependencies();
  registerProfileDependencies();

  // Add other feature-specific registrations here
  // registerAuthDependencies();
}
