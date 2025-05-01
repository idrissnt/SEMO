import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';
import 'package:semo/features/home/presentation/screens/home_screen.dart';

/// Registers the home tab in the tab registry
void registerHomeTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: AppRoutes.home,
      label: HomeConstants.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      screen: HomeScreen(),
    ),
  );
}
