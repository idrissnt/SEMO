import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/services/api_client.dart';
import 'package:semo/core/config/app_config.dart';
import 'package:semo/features/store/data/repositories/store_repository_impl.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';

import 'package:semo/features/auth/data/repositories/user_repository_impl.dart';
import 'package:semo/features/auth/domain/repositories/auth_repository.dart';

import 'package:semo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:semo/features/profile/domain/repositories/profile_repository.dart';

final sl = GetIt.instance; // Service Locator accessible anywhere in the app

Future<void> initializeDependencies() async {
  // Core
  sl.registerLazySingleton(() => AppLogger());
  sl.registerLazySingleton(() => Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
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
  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<UserAuthRepository>(
    () => UserAuthRepositoryImpl(
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
  sl.registerLazySingleton<BasicProfileRepository>(
    () => BasicProfileRepositoryImpl(
      dio: sl(),
      secureStorage: sl(),
    ),
  );

  // // Use Cases
  // sl.registerLazySingleton<GetStoresUseCase>(
  //   () => GetStoresUseCaseImpl(storeRepository: sl()),
  // );
}
