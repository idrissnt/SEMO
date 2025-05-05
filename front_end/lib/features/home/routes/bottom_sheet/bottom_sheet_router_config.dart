import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/home/presentation/full_screen_bottom_sheet/user_address_screen.dart';
import 'package:semo/features/home/routes/bottom_sheet/bottom_sheet_routes_constants.dart';

/// Configuration for bottom sheet router
///
/// This class is responsible for creating the routes for the bottom sheet navigator.
/// It follows the single responsibility principle by focusing only on route configuration.
class BottomSheetRouterConfig {
  /// Creates the routes for the bottom sheet navigator
  ///
  /// [initialPage] is the initial page to display when the bottom sheet is opened
  static List<RouteBase> createRoutes(Widget initialPage) {
    return [
      GoRoute(
        path: BottomSheetRoutesConstants.root,
        builder: (context, state) => initialPage,
      ),
      GoRoute(
        path: BottomSheetRoutesConstants.address,
        builder: (context, state) => const UserAddressScreen(),
      ),
      // Add more routes as needed
    ];
  }

  // Private constructor to prevent instantiation
  BottomSheetRouterConfig._();
}
