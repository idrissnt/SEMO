import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/features/community_shop/presentation/constant/constants.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';

/// Registers the earn tab in the tab registry
void registerCommunityShopTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: RouteConstants.communityShop,
      label: CommunityShopConstants.communityShop,
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt,
    ),
  );
}
