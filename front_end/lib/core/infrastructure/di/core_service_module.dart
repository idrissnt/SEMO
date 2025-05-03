import 'package:get_it/get_it.dart';
import 'package:semo/core/utils/logger.dart';

/// Dependency injection module for core services
///
/// This module registers fundamental services that are used across the application.
/// It follows clean architecture principles and ensures these services are registered
/// early in the application lifecycle.
///
/// This module is responsible for:
/// 1. Registering the logger service
/// 2. Registering other core utilities and services
class CoreServiceModule {
  /// Registers all core services
  static void register(GetIt getIt) {
    // Register logger first so it can be used during initialization
    if (!getIt.isRegistered<AppLogger>()) {
      getIt.registerLazySingleton<AppLogger>(() => AppLogger());
    }
    
    // Additional core services can be registered here
  }
}
