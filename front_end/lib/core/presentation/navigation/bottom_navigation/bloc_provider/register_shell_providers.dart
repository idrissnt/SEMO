import 'package:semo/core/presentation/navigation/bottom_navigation/bloc_provider/shell_provider.dart';
import 'package:semo/features/order/routes/order_shell_provider.dart';

/// Registers all shell providers from all features
/// This should be called during app initialization
void registerAllShellProviders() {
  // Register home feature provider
  ShellProviderRegistry.registerProvider(OrderShellProvider());

  // Other feature providers can be registered here
  // Example: ShellProviderRegistry.registerProvider(ProfileShellProvider());
}
