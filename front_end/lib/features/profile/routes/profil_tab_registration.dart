import 'package:flutter/cupertino.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// Registers the profile tab in the tab registry
void registerProfileTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: ProfileRoutesConstants.rootProfile,
      label: ProfileRoutesConstants.profileLabel,
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
    ),
  );
}
