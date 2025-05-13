import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/order/routes/const.dart';
import 'dart:developer' as dev;
import 'package:semo/features/store/presentation/navigation/store_tab_item.dart';

/// Coordinator class that handles navigation for the store detail screen
class StoreNavigationCoordinator {
  /// The build context for navigation
  final BuildContext context;

  /// The ID of the store
  final String storeId;

  /// Creates a new store navigation coordinator
  StoreNavigationCoordinator({
    required this.context,
    required this.storeId,
  });

  /// Navigates to a specific tab
  void navigateToTab(int index, List<StoreTabItem> tabs) {
    final baseRoute = '/store/$storeId';
    final tabRoute = tabs[index].route;

    dev.log('Navigating to tab: ${tabs[index].label} with route: $tabRoute');

    if (index == 0) {
      // For the first tab, just use the base route
      context.go(baseRoute);
    } else {
      // For other tabs, append the tab route
      context.go('$baseRoute/$tabRoute');
    }
  }

  /// Navigates back to the previous screen
  void navigateBack() {
    context.go(OrderRoutesConstants.order);
  }
}
