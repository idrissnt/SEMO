import 'package:get_it/get_it.dart';
import 'package:semo/features/auth/di/auth_injection.dart';
import 'package:semo/features/store/di/store_injection.dart';
import 'package:semo/features/order/di/order_injection.dart';
import 'package:semo/features/profile/di/profile_injection.dart';

/// Registry for all feature modules
///
/// This class centralizes the registration of all feature-specific modules.
/// It follows clean architecture principles by keeping feature modules separate
/// from core infrastructure.
///
/// This approach makes it easy to:
/// 1. Add new features without modifying the main injection container
/// 2. Enable/disable features as needed
/// 3. Maintain a clear separation between core and feature dependencies
class FeatureModuleRegistry {
  /// Registers all feature modules
  static void registerAll(GetIt getIt) {
    // Auth feature
    registerAuthDependencies();

    // Store feature
    registerStoreDependencies();

    // Order feature
    registerOrderDependencies();

    // Profile feature
    registerProfileDependencies();

    // Additional features can be registered here
  }
}
