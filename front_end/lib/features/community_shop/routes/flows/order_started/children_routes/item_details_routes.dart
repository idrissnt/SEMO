import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/core/presentation/screens/image_viewer_screen.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/item/item_found.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/item/item_not_found.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/item/order_item_detail.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/init_screen/utils/models.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/features/community_shop/routes/utils/route_builder.dart'
    as app_routes;

/// Routes for the item details flow
class ItemDetailsRoutes {
  /// Get all routes for the item details flow
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: RouteConstants.orderItemDetails,
        name: RouteConstants.orderItemDetailsName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: _buildItemDetailsScreen,
        routes: [
          // Image viewer route
          GoRoute(
            path: RouteConstants.imageViewer,
            name: RouteConstants.imageViewerName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildImageViewerScreen,
          ),
          // Order item details found route
          GoRoute(
            path: RouteConstants.orderItemDetailsFound,
            name: RouteConstants.orderItemDetailsFoundName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildItemFoundScreen,
          ),
          // Order item details not found route
          GoRoute(
            path: RouteConstants.orderItemDetailsNotFound,
            name: RouteConstants.orderItemDetailsNotFoundName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: _buildItemNotFoundScreen,
          ),
        ],
      ),
    ];
  }

  /// Build the item details screen
  static Page<dynamic> _buildItemDetailsScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    // First try to get the item and order from state.extra (for backward compatibility)
    OrderItem? orderItem =
        app_routes.RouteBuilder.getExtraParam<OrderItem>(state, 'orderItem');
    CommunityOrder? order =
        app_routes.RouteBuilder.getExtraParam<CommunityOrder>(state, 'order');

    // If item or order is null, try to fetch them based on the itemId parameter
    if (orderItem == null || order == null) {
      final itemId = state.pathParameters['itemId'];
      if (itemId != null) {
        // In a real app with BLoC, this would be a repository call
        // For now, we'll use the test data
        try {
          // Find the item by ID
          orderItem ??= OrderItem.getSampleItems()
              .firstWhere((item) => item.id == itemId);

          // If we have the item but not the order, we need to find a matching order
          // In a real app, we would have a proper relationship between items and orders
          // For now, we'll just use the first order in our test data
          order ??= getSampleCommunityOrders().first;
        } catch (e) {
          // Item not found in test data
          return app_routes.RouteBuilder.errorPage(
            context,
            state,
            'Item not found: $itemId',
          );
        }
      } else {
        return app_routes.RouteBuilder.errorPage(
          context,
          state,
          'Item ID not provided',
        );
      }
    }

    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: CommunityOrderItemDetailsScreen(
        orderItem: orderItem,
        order: order,
      ),
      name: 'CommunityOrderItemDetailsScreen',
    );
  }

  /// Build the image viewer screen
  static Page<dynamic> _buildImageViewerScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    final imageUrl =
        app_routes.RouteBuilder.getExtraParam<String>(state, 'imageUrl');
    final heroTag =
        app_routes.RouteBuilder.getExtraParam<String>(state, 'heroTag');

    if (imageUrl == null || heroTag == null) {
      return app_routes.RouteBuilder.errorPage(
        context,
        state,
        'Image URL or hero tag not provided',
      );
    }

    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: ImageViewerScreen(
        imageUrl: imageUrl,
        heroTag: heroTag,
      ),
      name: 'ImageViewerScreen',
    );
  }

  /// Build the item found screen
  static Page<dynamic> _buildItemFoundScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    final orderItem =
        app_routes.RouteBuilder.getExtraParam<OrderItem>(state, 'orderItem');
    final order =
        app_routes.RouteBuilder.getExtraParam<CommunityOrder>(state, 'order');

    if (orderItem == null || order == null) {
      return app_routes.RouteBuilder.errorPage(
        context,
        state,
        'Item or order not found for confirmation',
      );
    }

    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: CommunityOrderItemDetailsFoundScreen(
        orderItem: orderItem,
        order: order,
      ),
      name: 'CommunityOrderItemDetailsFoundScreen',
    );
  }

  /// Build the item not found screen
  static Page<dynamic> _buildItemNotFoundScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    final orderItem =
        app_routes.RouteBuilder.getExtraParam<OrderItem>(state, 'orderItem');
    final order =
        app_routes.RouteBuilder.getExtraParam<CommunityOrder>(state, 'order');
    final replacementItems =
        app_routes.RouteBuilder.getExtraParam<List<OrderItem>>(
            state, 'replacementItems');

    if (orderItem == null || order == null) {
      return app_routes.RouteBuilder.errorPage(
        context,
        state,
        'Item or order not found for not found screen',
      );
    }

    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: CommunityOrderItemNotFoundScreen(
        orderItem: orderItem,
        order: order,
        replacementItems: replacementItems,
      ),
      name: 'CommunityOrderItemNotFoundScreen',
    );
  }
}
