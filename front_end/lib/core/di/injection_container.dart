import 'package:get_it/get_it.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/infrastructure/di/core_service_module.dart';
import 'package:semo/core/infrastructure/di/dio_module.dart';
import 'package:semo/core/infrastructure/di/token_service_module.dart';
import 'package:semo/core/infrastructure/di/network_service_module.dart';
import 'package:semo/core/infrastructure/di/feature_module_registry.dart';

/// Service Locator accessible anywhere in the app
final sl = GetIt.instance;

/// Initializes all application dependencies
/// This is the main entry point for dependency injection
/// 
/// This follows a modular approach where each module is responsible for
/// registering its own dependencies. The modules are registered in a specific
/// order to ensure dependencies are available when needed.
Future<void> initializeDependencies() async {
  try {
    // 1. Register core services first (logger, etc.)
    CoreServiceModule.register(sl);
    
    // 2. Register Dio instances (required by both token and network services)
    DioModule.register(sl);
    
    // 3. Register token services (requires core services and Dio)
    TokenServiceModule.register(sl);
    
    // 4. Register network services (requires token services and Dio)
    NetworkServiceModule.register(sl);
    
    // 5. Register feature modules (requires core and network services)
    FeatureModuleRegistry.registerAll(sl);
    
    // Log successful initialization
    sl<AppLogger>().info('All dependencies initialized successfully');
  } catch (e, stackTrace) {
    // If AppLogger is registered, use it to log the error
    if (sl.isRegistered<AppLogger>()) {
      final logger = sl<AppLogger>();
      logger.error('Failed to initialize dependencies',
          error: e, stackTrace: stackTrace);
    }
    rethrow;
  }
}


