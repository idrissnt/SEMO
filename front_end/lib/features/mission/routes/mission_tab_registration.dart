import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';
import 'package:semo/features/mission/mission_screen.dart';

/// Registers the mission tab in the tab registry
void registerMissionTab() {
  TabRegistry.registerTab(
    const TabInfo(
      route: AppRoutes.mission,
      label: HomeConstants.publish,
      icon: Icons.note_add_outlined,
      activeIcon: Icons.note_add,
      screen: MissionScreen(),
    ),
  );
}
