import 'package:flutter/material.dart';
import 'package:semo/features/order/routes/const.dart';
import 'package:semo/features/store/presentation/navigation/store_navigation_coordinator.dart';
import 'package:semo/features/store/presentation/widgets/shared/app_bar.dart';

/// Factory class that creates different AppBars for each store tab
class StoreTabAppBarFactory {
  /// Creates an AppBar for the specified tab index
  static PreferredSizeWidget createAppBar({
    required int tabIndex,
    required String storeTitle,
    required StoreNavigationCoordinator coordinator,
    VoidCallback? onSearchTap,
    ValueChanged<String>? onSearchChanged,
    VoidCallback? onCartTap,
  }) {
    // Create an instance of AppBarBuilder to reuse its functionality
    final appBarBuilder = AppBarBuilder();

    switch (tabIndex) {
      case 0: // Shop tab
        return _createShopTabAppBar(
          storeTitle: storeTitle,
          coordinator: coordinator,
          onSearchTap: onSearchTap,
          onCartTap: onCartTap,
          appBarBuilder: appBarBuilder,
        );
      case 1: // Aisles tab
        return _createAislesTabAppBar(
          storeTitle: storeTitle,
          coordinator: coordinator,
          onSearchChanged: onSearchChanged,
          onCartTap: onCartTap,
          appBarBuilder: appBarBuilder,
        );
      case 2: // Buy Again tab
        return _createBuyAgainTabAppBar(
          storeTitle: storeTitle,
          coordinator: coordinator,
          onSearchTap: onSearchTap,
          onCartTap: onCartTap,
          appBarBuilder: appBarBuilder,
        );
      default:
        return _createDefaultAppBar(
          storeTitle: storeTitle,
          coordinator: coordinator,
          appBarBuilder: appBarBuilder,
        );
    }
  }

  /// Creates the AppBar for the Shop tab
  static PreferredSizeWidget _createShopTabAppBar({
    required String storeTitle,
    required StoreNavigationCoordinator coordinator,
    required AppBarBuilder appBarBuilder,
    VoidCallback? onSearchTap,
    VoidCallback? onCartTap,
  }) {
    return appBarBuilder.buildAppBar(
      coordinator.context,
      OrderRoutesConstants.order, // No back navigation for main tab
      true, //
      'Search products...', // Hint text
      (query) {
        // Handle search query
        if (onSearchTap != null) {
          onSearchTap();
        }
      },
    );
  }

  /// Creates the AppBar for the Aisles tab with search functionality
  static PreferredSizeWidget _createAislesTabAppBar({
    required String storeTitle,
    required StoreNavigationCoordinator coordinator,
    required AppBarBuilder appBarBuilder,
    ValueChanged<String>? onSearchChanged,
    VoidCallback? onCartTap,
  }) {
    return appBarBuilder.buildAppBar(
      coordinator.context,
      '', // No back navigation for main tab
      false, // No leading icon for main tab
      'Search aisles...', // Hint text
      (query) {
        // Handle search query
        if (onSearchChanged != null) {
          onSearchChanged(query);
        }
      },
      disableBackButton: true, // Explicitly disable back button
    );
  }

  /// Creates the AppBar for the Buy Again tab
  static PreferredSizeWidget _createBuyAgainTabAppBar({
    required String storeTitle,
    required StoreNavigationCoordinator coordinator,
    required AppBarBuilder appBarBuilder,
    VoidCallback? onSearchTap,
    VoidCallback? onCartTap,
  }) {
    return appBarBuilder.buildAppBar(
      coordinator.context,
      '', // No back navigation for main tab
      false, // No leading icon for main tab
      'Search previous orders...', // Hint text
      (query) {
        // Handle search query
        if (onSearchTap != null) {
          onSearchTap();
        }
      },
    );
  }

  /// Creates a default AppBar as fallback
  static PreferredSizeWidget _createDefaultAppBar({
    required String storeTitle,
    required StoreNavigationCoordinator coordinator,
    required AppBarBuilder appBarBuilder,
  }) {
    return appBarBuilder.buildAppBar(
      coordinator.context,
      '', // No specific route
      true, // Show back button
      'Search...', // Generic hint text
      (query) {
        // Handle search query
      },
    );
  }
}
