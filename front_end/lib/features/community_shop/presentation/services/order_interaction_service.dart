import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';
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

  /// Handles accepting an order - removes it from available orders
  void handleOrderAccept(
    BuildContext context,
    CommunityOrder order,
    Function(CommunityOrder) onOrderAccepted,
  ) {
    _logger.info('Order accepted: ${order.id}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous avez accepté la commande de ${order.customerName}'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Call the callback to update the state in the parent widget
    onOrderAccepted(order);
  }
}
