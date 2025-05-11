import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/order/presentation/bottom_sheets/address_app_bar/address_edit_screen.dart';
import 'package:semo/features/order/presentation/bottom_sheets/after_register/get_user_address_screen.dart';
import 'package:semo/features/order/routes/bottom_sheet/after_register/routes_constants.dart';

/// Configuration for bottom sheet router
///
/// This class is responsible for creating the routes for the bottom sheet navigator.
/// It follows the single responsibility principle by focusing only on route configuration.
class BottomSheetRouterConfig {
  /// Creates the routes for the bottom sheet navigator when user is registered
  ///
  /// [initialPage] is the initial page to display when the bottom sheet is opened
  static List<RouteBase> createRoutes(Widget initialPage) {
    return [
      GoRoute(
        path: RegisterVerificationSheetRoutesConstants.root,
        builder: (context, state) => initialPage,
      ),
      GoRoute(
        path: RegisterVerificationSheetRoutesConstants.address,
        builder: (context, state) => const UserAddressScreen(),
      ),
      GoRoute(
        path: RegisterVerificationSheetRoutesConstants.addressEdit,
        builder: (context, state) => const AddressEditScreen(),
      ),
    ];
  }

  // Private constructor to prevent instantiation
  BottomSheetRouterConfig._();
}
