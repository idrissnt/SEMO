import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/deliver/deliver_screen.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';

/// Registers the earn tab in the tab registry
void registerDeliverTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: AppRoutes.deliver,
      label: HomeConstants.deliver,
      icon: Icons.emoji_people_outlined,
      activeIcon: Icons.emoji_people,
      screen: DeliverScreen(),
    ),
  );
}
