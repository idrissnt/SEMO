import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/initial_screen/order_starte_screen.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/item/add_item.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/features/community_shop/routes/flows/order_started/children_routes/item_details_routes.dart';
import 'package:semo/features/community_shop/routes/flows/order_started/children_routes/checkout_routes.dart';
import 'package:semo/core/presentation/navigation/config/route_builder.dart'
    as app_routes;
import 'package:semo/core/utils/logger.dart';

// Global logger instance
final AppLogger _logger = AppLogger();

/// Routes for the order started flow
class OrderStartedRoutes {
  /// Get all routes for the order started flow
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: RouteConstants.orderStart,
        name: RouteConstants.orderStartName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildOrderStartedScreen,
        routes: [
          ...ItemDetailsRoutes.getRoutes(),
          ...CheckoutRoutes.getRoutes(),
          // Add new item route
          GoRoute(
            path: RouteConstants.orderAddItem,
            name: RouteConstants.orderAddItemName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildAddItemScreen,
          ),
        ],
      ),
    ];
  }

  /// Build the order started screen
  static Page<dynamic> _buildOrderStartedScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    // First try to get the order from state.extra (for backward compatibility)
    List<CommunityOrder>? orders;

    // Check if state.extra is directly a List<CommunityOrder>
    if (state.extra is List<CommunityOrder>) {
      orders = state.extra as List<CommunityOrder>;
      _logger.info(
          'Found orders directly in state.extra: ${orders.length} orders');
    } else {
      // Try to get it as a named parameter
      orders = app_routes.RouteBuilder.getExtraParam<List<CommunityOrder>>(
          state, 'orders');
    }

    // If order is null, try to fetch it based on the orderId parameter
    if (orders == null) {
      final orderId = state.pathParameters['orderId'];
      if (orderId != null) {
        // In a real app with BLoC, this would be a repository call
        // For now, we'll use the test data
        try {
          orders =
              getSampleCommunityOrders().where((o) => o.id == orderId).toList();
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

    return app_routes.RouteBuilder.buildBottomToTopPage(
      context: context,
      state: state,
      child: CommunityOrderStartedScreen(orders: orders),
      name: 'CommunityOrderStartedScreen',
    );
  }

  /// Build the add item screen
  static Page<dynamic> _buildAddItemScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    // First try to get the order from state.extra
    CommunityOrder? order =
        app_routes.RouteBuilder.getExtraParam<CommunityOrder>(state, 'order');

    // If order is null, try to fetch it based on the orderId parameter
    if (order == null) {
      final orderId = state.pathParameters['orderId'];
      if (orderId != null) {
        try {
          // Find the order by ID
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
      child: AddItemScreen(
        order: order,
      ),
      name: 'AddItemScreen',
    );
  }
}
