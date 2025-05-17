import 'package:flutter/material.dart';
import 'package:semo/features/store/presentation/navigation/store_navigation_coordinator.dart';
import 'package:semo/features/store/presentation/widgets/app_bar/shared/app_bar.dart';

/// Factory class that creates different AppBars for each store tab
class StoreTabAppBarFactory {
  /// Creates an AppBar for the specified tab index
  static PreferredSizeWidget createAppBar({
    required int tabIndex,
    required StoreNavigationCoordinator coordinator,
    VoidCallback? onSearchTap,
    ValueChanged<String>? onSearchChanged,
  }) {
    // Create an instance of AppBarBuilder to reuse its functionality
    final appBarBuilder = AppBarBuilder();

    switch (tabIndex) {
      case 1: // Aisles tab
        return _createAislesTabAppBar(
          coordinator: coordinator,
          onSearchChanged: onSearchChanged,
          appBarBuilder: appBarBuilder,
        );
      case 2: // Buy Again tab
        return _createBuyAgainTabAppBar(
          coordinator: coordinator,
          onSearchTap: onSearchTap,
          appBarBuilder: appBarBuilder,
        );
      default:
        return _createDefaultAppBar(
          coordinator: coordinator,
          appBarBuilder: appBarBuilder,
        );
    }
  }

  /// Creates the AppBar for the Aisles tab with search functionality
  static PreferredSizeWidget _createAislesTabAppBar({
    required StoreNavigationCoordinator coordinator,
    required AppBarBuilder appBarBuilder,
    ValueChanged<String>? onSearchChanged,
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
    required StoreNavigationCoordinator coordinator,
    required AppBarBuilder appBarBuilder,
    VoidCallback? onSearchTap,
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
