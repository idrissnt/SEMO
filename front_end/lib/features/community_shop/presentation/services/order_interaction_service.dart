import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/models.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/const.dart';

/// Service class that handles interactions with community orders
class OrderInteractionService {
  final AppLogger _logger = AppLogger();

  /// Handles tapping on an order - shows details
  void handleOrderTap(BuildContext context, CommunityOrder order) {
    _logger.info('Order tapped: ${order.id}');
    context.pushNamed(
      CommunityShopRoutesConstants.orderDetailsName,
      extra: order,
    );
  }

  void handleDeliveryTimeSelection(
      BuildContext context, CommunityOrder order) {}

  void handleOrderStart(BuildContext context, CommunityOrder order) {
    context.pushNamed(
      CommunityShopRoutesConstants.orderStartName,
      extra: order,
    );
  }
}

class OrderProcessingInteractionService {
  final AppLogger _logger = AppLogger();

  void handleOrderItemTap(
      BuildContext context, OrderItem orderItem, CommunityOrder order) {
    _logger.info('Order item tapped: ${orderItem.id}');
    context.pushNamed(
      CommunityShopRoutesConstants.orderItemDetailsName,
      extra: {
        'orderItem': orderItem,
        'order': order,
      },
    );
  }

  void handleOrderItemConfirm(
      BuildContext context, OrderItem orderItem, CommunityOrder order) {
    _logger.info('Order item confirmed: ${orderItem.id}');
    context.pushNamed(
      CommunityShopRoutesConstants.orderItemDetailsConfirmationName,
      extra: {
        'orderItem': orderItem,
        'order': order,
      },
    );
  }
}
