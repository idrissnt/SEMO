import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/core/presentation/navigation/config/route_builder.dart'
    as app_routes;
import 'package:semo/features/profile/presentation/screens/account_screens/personal_informations/password.dart';
import 'package:semo/features/profile/routes/constant/account_route_const.dart';

/// Routes for the checkout and delivery flow
class PasswordRoutes {
  /// Get all routes for the checkout flow
  static List<RouteBase> getRoutes() {
    return [
      // Checkout route
      GoRoute(
        path: AccountRoutesConstants.password,
        name: AccountRouteNames.passwordName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildPasswordScreen,
      ),
    ];
  }

  /// Build the checkout screen
  static Page<dynamic> _buildPasswordScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const PasswordScreen(),
      name: 'PasswordScreen',
    );
  }
}
