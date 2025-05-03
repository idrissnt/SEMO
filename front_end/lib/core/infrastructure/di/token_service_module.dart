import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:semo/core/domain/services/secure_token_storage.dart';
import 'package:semo/core/domain/services/token_service.dart';
import 'package:semo/core/infrastructure/di/di_constants.dart';
import 'package:semo/core/infrastructure/utils/token_cache.dart';
import 'package:semo/core/infrastructure/services/token_service_impl.dart';
import 'package:semo/core/infrastructure/services/secure_token_storage_impl.dart';
import 'package:semo/core/utils/logger.dart';

/// Dependency injection module for token management
///
/// This module registers all token-related dependencies in the GetIt service locator.
/// It follows clean architecture principles by registering interfaces from the domain layer
/// and their implementations from the infrastructure layer.
///
/// This module is responsible for:
/// 1. Registering the secure storage with enhanced security options
/// 2. Registering the token storage implementation
/// 3. Registering the token service
class TokenServiceModule {
  /// Registers all token-related dependencies with enhanced security options
  static void register(GetIt getIt) {
    // Register logger if not already registered
    if (!getIt.isRegistered<AppLogger>()) {
      getIt.registerLazySingleton<AppLogger>(() => AppLogger());
    }

    // Register secure storage with enhanced security options if not already registered
    if (!getIt.isRegistered<FlutterSecureStorage>()) {
      getIt.registerLazySingleton<FlutterSecureStorage>(
          () => const FlutterSecureStorage(
                aOptions: AndroidOptions(
                  encryptedSharedPreferences: true,
                ),
                iOptions: IOSOptions(
                  accessibility: KeychainAccessibility.first_unlock,
                ),
              ));
    }

    // Register TokenCache as a singleton
    getIt.registerLazySingleton<TokenCache>(() => TokenCache());

    // Register TokenStorage implementation
    getIt.registerLazySingleton<TokenStorage>(() => SecureTokenStorage(
          storage: getIt<FlutterSecureStorage>(),
        ));

    // Register TokenService implementation
    // Note: We're registering the interface from the domain layer
    // but the implementation is from the infrastructure layer
    getIt.registerLazySingleton<TokenService>(() => TokenServiceImpl(
          dio: getIt<Dio>(instanceName: DIConstants.tokenServiceDio),
          storage: getIt<TokenStorage>(),
          cache: getIt<TokenCache>(),
          logger: getIt<AppLogger>(),
        ));
  }
}
