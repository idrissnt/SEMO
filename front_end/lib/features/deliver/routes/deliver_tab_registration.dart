import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/features/deliver/routes/const.dart';
import 'package:semo/features/deliver/presentation/constant/constants.dart';

/// Registers the earn tab in the tab registry
void registerDeliverTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: DeliverRoutesConstants.deliver,
      label: DeliverConstants.deliver,
      icon: Icons.people_alt_outlined,
      activeIcon: Icons.people_alt,
    ),
  );
}
