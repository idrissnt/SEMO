import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';
import 'package:semo/features/message/message_screen.dart';

/// Registers the message tab in the tab registry
void registerMessageTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: AppRoutes.message,
      label: HomeConstants.message,
      icon: Icons.message_outlined,
      activeIcon: Icons.message,
      screen: MessageScreen(),
    ),
  );
}
