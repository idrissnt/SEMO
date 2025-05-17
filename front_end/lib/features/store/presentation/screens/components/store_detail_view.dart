import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/store/presentation/navigation/store_navigation_coordinator.dart';
import 'package:semo/features/store/presentation/navigation/store_tab_controller.dart';
import 'package:semo/features/store/presentation/navigation/store_tab_item.dart';
import 'package:semo/features/store/presentation/screens/tabs/store_aisles_tab.dart';
import 'package:semo/features/store/presentation/screens/tabs/store_buy_again_tab.dart';
import 'package:semo/features/store/presentation/screens/tabs/store_shop_tab.dart';
import 'package:semo/features/store/presentation/widgets/store/bottom_nav_bar.dart';
import 'package:semo/features/store/presentation/widgets/store/app_bar_factory_store_tab.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

final _logger = AppLogger();

/// The view component for the store detail screen
class StoreDetailView extends StatefulWidget {
  /// The ID of the store
  final String storeId;

  const StoreDetailView({Key? key, required this.storeId}) : super(key: key);

  @override
  State<StoreDetailView> createState() => _StoreDetailViewState();
}

class _StoreDetailViewState extends State<StoreDetailView> {
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

  @override
  Widget build(BuildContext context) {
    // Create the coordinator locally instead of getting it from Provider
    final coordinator = StoreNavigationCoordinator(
      context: context,
      storeId: widget.storeId,
    );
    final tabController = Provider.of<StoreTabController>(context);

    // Only show app bar for non-shop tabs (index != 0)
    // Shop tab has its own animated app bar
    return Scaffold(
      appBar: tabController.selectedIndex != 0
          ? _buildAppBar(tabController.selectedIndex, coordinator)
          : null,
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

  /// Builds a custom AppBar based on the selected tab
  PreferredSizeWidget _buildAppBar(
      int selectedIndex, StoreNavigationCoordinator coordinator) {
    return StoreTabAppBarFactory.createAppBar(
      tabIndex: selectedIndex,
      coordinator: coordinator,
      onSearchTap: () {
        // Handle search tap
        _logger.debug('Search tapped');
      },
      onSearchChanged: (query) {
        // Handle search query
        _logger.debug('Searching for: $query');
      },
    );
  }

  /// Builds the body based on the selected tab
  Widget _buildBody(int selectedIndex) {
    // Use IndexedStack to preserve state of each tab
    // In the future we will use BLoC to store tab-specific state
    return IndexedStack(
      index: selectedIndex,
      children: [
        StoreShopTab(
          storeId: widget.storeId,
        ),
        StoreAislesTab(storeId: widget.storeId),
        StoreBuyAgainTab(storeId: widget.storeId),
      ],
    );
  }
}
