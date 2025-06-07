import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/core/presentation/navigation/config/route_builder.dart'
    as app_routes;
import 'package:semo/features/profile/presentation/screens/account_screens/personal_informations/payment_methods.dart';
import 'package:semo/features/profile/routes/constant/account_route_const.dart';

/// Routes for the checkout and delivery flow
class PaymentMethodsRoutes {
  /// Get all routes for the checkout flow
  static List<RouteBase> getRoutes() {
    return [
      // Checkout route
      GoRoute(
        path: AccountRoutesConstants.paymentMethods,
        name: AccountRouteNames.paymentMethodsName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildPaymentMethodsScreen,
      ),
    ];
  }

  /// Build the checkout screen
  static Page<dynamic> _buildPaymentMethodsScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const PaymentMethodsScreen(),
      name: 'PaymentMethodsScreen',
    );
  }
}
