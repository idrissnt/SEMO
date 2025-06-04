import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/deliveries/order_information.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/payment/checkout.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/initial_screen/utils/models.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/features/community_shop/routes/utils/route_builder.dart'
    as app_routes;

/// Routes for the checkout and delivery flow
class CheckoutRoutes {
  /// Get all routes for the checkout flow
  static List<RouteBase> getRoutes() {
    return [
      // Checkout route
      GoRoute(
        path: RouteConstants.orderCheckout,
        name: RouteConstants.orderCheckoutName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildCheckoutScreen,
      ),

      // Delivery order information route
      GoRoute(
        path: RouteConstants.deliveryOrderInformation,
        name: RouteConstants.deliveryOrderInformationName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildDeliveryOrderInformationScreen,
      ),
    ];
  }

  /// Build the checkout screen
  static Page<dynamic> _buildCheckoutScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    final orders = app_routes.RouteBuilder.getExtraParam<List<CommunityOrder>>(
        state, 'orders');
    final orderItem =
        app_routes.RouteBuilder.getExtraParam<OrderItem>(state, 'orderItem');

    if (orders == null || orderItem == null) {
      return app_routes.RouteBuilder.errorPage(
        context,
        state,
        'Orders or order item not provided for checkout',
      );
    }

    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: CommunityOrderCheckoutScreen(
        orders: orders,
        orderItem: orderItem,
      ),
      name: 'CommunityOrderCheckoutScreen',
    );
  }

  /// Build the delivery order information screen
  static Page<dynamic> _buildDeliveryOrderInformationScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    final orders = app_routes.RouteBuilder.getExtraParam<List<CommunityOrder>>(
        state, 'orders');
    final orderItem =
        app_routes.RouteBuilder.getExtraParam<OrderItem>(state, 'orderItem');

    if (orders == null || orderItem == null) {
      return app_routes.RouteBuilder.errorPage(
        context,
        state,
        'Orders not provided for delivery information',
      );
    }

    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child:
          DeliveryOrderInformationScreen(orders: orders, orderItem: orderItem),
      name: 'DeliveryOrderInformationScreen',
    );
  }
}
