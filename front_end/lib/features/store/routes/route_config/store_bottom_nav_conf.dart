import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/routes/tabs/store_tab_registry.dart';

class StoreNavigationScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const StoreNavigationScaffold({
    Key? key,
    required this.navigationShell,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = StoreTabRegistry.tabs;

    return Scaffold(
      // Use the children in an IndexedStack
      body: IndexedStack(
        index: navigationShell.currentIndex,
        children: children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        // Customize bottom navigation bar colors
        backgroundColor: AppColors.bottomNavigationColor, // Background color
        selectedItemColor: AppColors.primary, // Active item color
        unselectedItemColor: AppColors.textPrimaryColor, // Inactive item color
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        elevation: 8, // Add a slight shadow
        items: tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}
