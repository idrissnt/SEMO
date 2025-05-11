import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:semo/core/presentation/navigation/bottom_navigation/bloc_provider/shell_provider.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_info.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/tab_registry.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// Creates the main shell route with bottom navigation
/// This is in the core module because it's a cross-feature concern
ShellRoute getMainShellRoute() {
  // Get all registered tabs from the registry
  final tabs = TabRegistry.tabs;

  return ShellRoute(
    builder: (context, state, child) {
      // Get all BlocProviders from the registry
      final providers = ShellProviderRegistry.getAllBlocProviders();

      // Check if the current route is one of our tab routes
      final location = state.uri.path;
      final isTabRoute = tabs.any((tab) => location.startsWith(tab.route));

      // If this is not a tab route, show the child (external route)
      if (!isTabRoute && child != const SizedBox()) {
        return child;
      }

      return MultiBlocProvider(
        // Use providers from all features instead of hardcoding them here
        providers: providers,
        child: MainShellScaffold(tabs: tabs, state: state),
      );
    },
    routes: tabs
        .map((tab) => GoRoute(
              path: tab.route,
              builder: (_, __) => const SizedBox(), // Empty placeholder
            ))
        .toList(),
  );
}

/// The main scaffold with bottom navigation
/// This is extracted to a separate widget for better organization
class MainShellScaffold extends StatelessWidget {
  final List<TabInfo> tabs;
  final GoRouterState state;

  const MainShellScaffold({
    Key? key,
    required this.tabs,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the current tab index based on the route
    final location = state.uri.path;
    final currentIndex = tabs.indexWhere(
      (tab) => location.startsWith(tab.route),
    );

    // Default to first tab if no match found
    final selectedIndex = currentIndex >= 0 ? currentIndex : 0;

    return Scaffold(
      // Use IndexedStack to preserve state of all tabs
      body: IndexedStack(
        index: selectedIndex,
        children: tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          // Navigate to the selected tab
          context.go(tabs[index].route);
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
