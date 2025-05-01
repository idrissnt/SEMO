import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/earn/earn_screen.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';

/// Registers the earn tab in the tab registry
void registerEarnTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: AppRoutes.earn,
      label: HomeConstants.earn,
      icon: Icons.emoji_people_outlined,
      activeIcon: Icons.emoji_people,
      screen: EarnScreen(),
    ),
  );
}
