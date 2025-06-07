import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/community_order_details_screen.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/core/presentation/navigation/config/route_builder.dart'
    as app_routes;

/// Routes for the order details flow
class OrderDetailsRoutes {
  /// Get all routes for the order details flow
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: RouteConstants.orderDetails,
        name: RouteConstants.orderDetailsName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildOrderDetailsScreen,
      ),
    ];
  }

  /// Build the order details screen
  static Page<dynamic> _buildOrderDetailsScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    // First try to get the order from state.extra (for backward compatibility)
    CommunityOrder? order =
        app_routes.RouteBuilder.getExtraParam<CommunityOrder>(state, 'order');

    // If order is null, try to fetch it based on the orderId parameter
    if (order == null) {
      final orderId = state.pathParameters['orderId'];
      if (orderId != null) {
        // In a real app with BLoC, this would be a repository call
        // For now, we'll use the test data
        try {
          order = getSampleCommunityOrders().firstWhere((o) => o.id == orderId);
        } catch (e) {
          // Order not found in test data
          return app_routes.RouteBuilder.errorPage(
            context,
            state,
            'Order not found: $orderId',
          );
        }
      } else {
        return app_routes.RouteBuilder.errorPage(
          context,
          state,
          'Order ID not provided',
        );
      }
    }

    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: CommunityOrderDetailsScreen(order: order),
      name: 'CommunityOrderDetailsScreen',
    );
  }
}
