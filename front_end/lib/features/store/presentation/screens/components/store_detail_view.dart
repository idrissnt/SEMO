import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semo/features/store/presentation/navigation/store_navigation_coordinator.dart';
import 'package:semo/features/store/presentation/navigation/store_tab_controller.dart';
import 'package:semo/features/store/presentation/navigation/store_tab_item.dart';
import 'package:semo/features/store/presentation/screens/tabs/store_aisles_tab.dart';
import 'package:semo/features/store/presentation/screens/tabs/store_buy_again_tab.dart';
import 'package:semo/features/store/presentation/screens/tabs/store_shop_tab.dart';
import 'package:semo/features/store/presentation/widgets/store_bottom_nav_bar.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// The view component for the store detail screen
class StoreDetailView extends StatelessWidget {
  /// The ID of the store
  final String storeId;

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

  /// Creates a new store detail view
  const StoreDetailView({
    Key? key,
    required this.storeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = Provider.of<StoreTabController>(context);
    final coordinator = StoreNavigationCoordinator(
      context: context,
      storeId: storeId,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: coordinator.navigateBack,
        ),
        title: const Text('Nom du magasin'), // Placeholder for store name
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: _buildBody(tabController.selectedIndex),
      bottomNavigationBar: StoreBottomNavBar(
        selectedIndex: tabController.selectedIndex,
        onTap: (index) {
          // Just update the tab controller, don't navigate via URL
          tabController.setTab(index);
        },
        tabs: _tabs,
      ),
    );
  }

  /// Builds the body based on the selected tab
  Widget _buildBody(int selectedIndex) {
    // Use IndexedStack to preserve state of each tab
    // In the futue we will BLoC to Store tab-specific state in
    return IndexedStack(
      index: selectedIndex,
      children: [
        StoreShopTab(storeId: storeId),
        StoreAislesTab(storeId: storeId),
        StoreBuyAgainTab(storeId: storeId),
      ],
    );

    // switch (selectedIndex) {
    //   case 0:
    //     return StoreShopTab(storeId: storeId);
    //   case 1:
    //     return StoreAislesTab(storeId: storeId);
    //   case 2:
    //     return StoreBuyAgainTab(storeId: storeId);
    //   default:
    //     return StoreShopTab(storeId: storeId);
    // }
  }
}
