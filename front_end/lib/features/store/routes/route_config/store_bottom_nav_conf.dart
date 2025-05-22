import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/routes/tabs/store_tab_registry.dart';
import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

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
        onTap: (index) {
          // Check if user is tapping the current tab
          if (index == navigationShell.currentIndex) {
            // If we're already on this tab, check if we can go back to root
            final canPop = GoRouter.of(context).canPop();

            if (canPop) {
              // We're in a nested route, navigate back to the root route of this tab
              // Get the tabs from the registry
              final allTabs = StoreTabRegistry.tabs;

              // Check if the index is valid
              if (index >= 0 && index < allTabs.length) {
                // Get the root route for this tab
                final rootRoute = allTabs[index].route;

                // Navigate to the root route for this tab
                GoRouter.of(context).go(rootRoute);

                _logger.info('Navigating back to root route: $rootRoute');
              } else {
                // Fallback to the current branch
                navigationShell.goBranch(index);
              }
              return; // Don't call goBranch as we've handled navigation
            } else {
              // We're already at the root, so refresh data
              // This could be implemented by sending an event to your state management system
              // For example, if using BLoC:
              // context.read<YourBloc>().add(RefreshDataEvent());

              // For now, just print a message
              _logger.info('Refreshing data for tab $index');
            }
          }

          // If we're switching tabs or haven't returned early, navigate to the branch
          navigationShell.goBranch(index);
        },
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
