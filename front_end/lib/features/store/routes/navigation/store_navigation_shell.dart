import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/routes/navigation/store_tab_item.dart';
import 'package:semo/features/store/presentation/widgets/store/bottom_nav_bar.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// A navigation shell for the store feature that handles bottom navigation
class StoreNavigationShell extends StatelessWidget {
  /// The ID of the store
  final String storeId;

  /// The index of the currently selected tab
  final int selectedIndex;

  /// The child widget to display (provided by the router)
  final Widget child;

  /// List of available tabs
  static const List<StoreTabItem> _tabs = [
    StoreTabItem(
      icon: Icons.shopping_bag,
      label: 'Nom du magasin',
      route: '', // Base route
    ),
    StoreTabItem(
      icon: Icons.grid_view,
      label: 'Rayons',
      route: StoreRoutesConst.storeAisles,
    ),
    StoreTabItem(
      icon: Icons.replay,
      label: 'Achats encore',
      route: StoreRoutesConst.storeBuyAgain,
    ),
  ];

  /// Creates a new store navigation shell
  const StoreNavigationShell({
    Key? key,
    required this.storeId,
    required this.selectedIndex,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: StoreBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) => _onTabTapped(context, index),
        tabs: _tabs,
      ),
    );
  }

  /// Handle tab tapped event
  void _onTabTapped(BuildContext context, int index) {
    if (index == selectedIndex) {
      // Already on this tab, do nothing
      return;
    }

    // Navigate to the appropriate route based on the tab index
    switch (index) {
      case 0:
        // Shop tab (default)
        context.go(StoreRoutesConst.getStoreDetailRoute(storeId));
        break;
      case 1:
        // Aisles tab
        context.go(StoreRoutesConst.getStoreAislesRoute(storeId));
        break;
      case 2:
        // Buy Again tab
        context.go(StoreRoutesConst.getStoreBuyAgainRoute(storeId));
        break;
    }
  }
}
