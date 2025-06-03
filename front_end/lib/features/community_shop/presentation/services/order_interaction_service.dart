import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/models.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';

/// Service class that handles interactions with community orders
class OrderInteractionService {
  final AppLogger _logger = AppLogger();

  /// Handles tapping on an order - shows details
  void handleOrderTap(BuildContext context, CommunityOrder order) {
    _logger.info('Order tapped: ${order.id}');
    context.pushNamed(
      RouteConstants.orderDetailsName,
      pathParameters: {'orderId': order.id},
      extra:
          order, // Still passing the order object for now until BLoC is implemented
    );
  }

  void handleDeliveryTimeSelection(
      BuildContext context, CommunityOrder order) {}

  void handleOrderStart(BuildContext context, CommunityOrder order) {
    context.pushNamed(
      RouteConstants.orderStartName,
      pathParameters: {'orderId': order.id},
      extra:
          order, // Still passing the order object for now until BLoC is implemented
    );
  }
}

class OrderProcessingInteractionService {
  final AppLogger _logger = AppLogger();

  void handleOrderItemTap(
      BuildContext context, OrderItem orderItem, CommunityOrder order) {
    _logger.info('Order item tapped: ${orderItem.id}');
    // Use named route with both orderId and itemId parameters
    context.pushNamed(
      RouteConstants.orderItemDetailsName,
      pathParameters: {
        'orderId': order.id,
        'itemId': orderItem.id,
      },
      extra: {
        'orderItem': orderItem,
        'order': order,
      }, // Still passing objects for now until BLoC is implemented
    );

    // Alternative approach using path construction helper (commented out for reference)
    // final path = RouteConstants.getFullOrderItemDetailsPath(order.id, orderItem.id);
    // context.push(path, extra: {'orderItem': orderItem, 'order': order});
  }

  void handleOrderItemFound(
      BuildContext context, OrderItem orderItem, CommunityOrder order) {
    _logger.info('Order item confirmed: ${orderItem.id}');
    context.pushNamed(
      RouteConstants.orderItemDetailsFoundName,
      pathParameters: {
        'orderId': order.id, // Include orderId parameter for the parent route
        'itemId': orderItem.id,
      },
      extra: {
        'orderItem': orderItem,
        'order': order,
      },
    );
  }

  /// Handle navigation when an item is not found
  void handleOrderItemNotFound(
      BuildContext context, OrderItem orderItem, CommunityOrder order,
      {List<OrderItem>? replacementItems}) {
    _logger.info('Order item not found: ${orderItem.id}');
    context.pushNamed(
      RouteConstants.orderItemDetailsNotFoundName,
      pathParameters: {
        'orderId': order.id, // Include orderId parameter for the parent route
        'itemId': orderItem.id,
      },
      extra: {
        'orderItem': orderItem,
        'order': order,
        'replacementItems': replacementItems,
      },
    );
  }

  void handleOrderStartCheckout(
      BuildContext context, List<CommunityOrder> orders, String customerName) {
    // Get the orderId from the first order in the list
    final orderId = orders.isNotEmpty ? orders.first.id : '';

    // Include the orderId parameter since checkout is nested under order-start
    context.pushNamed(
      RouteConstants.orderCheckoutName,
      pathParameters: {'orderId': orderId},
      extra: {
        'orders': orders,
      },
    );
  }

  void firstOrderShopperMessageName(
      BuildContext context, CommunityOrder order) {
    context.pushNamed(
      RouteConstants.firstOrderShopperMessageName,
      extra: {
        'orders': [order],
      }, // Updating to match the expected parameter format in the route
    );
  }

  void handleDeliveryOrderInformation(
      BuildContext context, List<CommunityOrder> orders) {
    // Get the orderId from the first order in the list
    final orderId = orders.isNotEmpty ? orders.first.id : '';

    // Include the orderId parameter since delivery information is nested under order-start
    context.pushNamed(
      RouteConstants.deliveryOrderInformationName,
      pathParameters: {'orderId': orderId},
      extra: {'orders': orders},
    );
  }

  /// Handle navigation to add a new item to the order
  void handleAddNewItem(BuildContext context, CommunityOrder order) {
    _logger.info('Adding new item to order: ${order.id}');

    context.pushNamed(
      RouteConstants.orderAddItemName,
      pathParameters: {
        'orderId': order.id, // Include orderId parameter for the parent route
      },
      extra: {
        'order': order,
      },
    ).then((newItem) {
      // Handle the returned item if any
      if (newItem != null && newItem is OrderItem) {
        _logger.info('New item added: ${newItem.name}');
        // In a real app with BLoC, this would dispatch an event to add the item
        // For now, we'll just show a snackbar
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produit ajouté: ${newItem.name}')),
          );
        }
      }
    });
  }
}
