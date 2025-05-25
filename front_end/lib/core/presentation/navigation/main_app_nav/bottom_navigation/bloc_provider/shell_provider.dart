import 'package:flutter_bloc/flutter_bloc.dart';

/// A provider for feature-specific BLoCs in the shell route
/// This follows the provider pattern to allow features to provide their BLoCs
/// without the core module directly depending on them
abstract class ShellBlocProvider {
  /// Get the BlocProviders for this feature
  List<BlocProvider> getBlocProviders();
}

/// Registry for all shell BlocProviders
/// This allows features to register their BlocProviders without the core module
/// directly depending on them
class ShellProviderRegistry {
  /// Private list of registered providers
  static final List<ShellBlocProvider> _providers = [];

  /// Register a new provider
  static void registerProvider(ShellBlocProvider provider) {
    _providers.add(provider);
  }

  /// Get all registered BlocProviders
  static List<BlocProvider> getAllBlocProviders() {
    return _providers
        .expand((provider) => provider.getBlocProviders())
        .toList();
  }

  /// Clear all registered providers (useful for testing)
  static void clear() {
    _providers.clear();
  }
}
