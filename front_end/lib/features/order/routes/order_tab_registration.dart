import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/features/order/presentation/constant/constants.dart';
import 'package:semo/features/order/routes/const.dart';

/// Registers the order tab in the tab registry
void registerOrderTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: OrderRoutesConstants.order,
      label: OrderConstants.order,
      icon: Icons.shopping_basket_outlined,
      activeIcon: Icons.shopping_basket,
    ),
  );
}
