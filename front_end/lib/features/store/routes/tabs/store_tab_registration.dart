import 'package:flutter/material.dart';
import 'package:semo/features/store/routes/route_config/store_routes_const.dart';
import 'package:semo/features/store/routes/tabs/store_tab_info.dart';
import 'package:semo/features/store/routes/tabs/store_tab_registry.dart';

/// Registers the order tab in the tab registry
void registerStoreTab() {
  StoreTabRegistry.registerTab(
    StoreTabInfo(
      route: StoreRoutesConst.storeBase,
      label: 'Nom du magasin',
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
    ),
  );
}

void registerStoreBuyAgainTab() {
  StoreTabRegistry.registerTab(
    StoreTabInfo(
      route: StoreRoutesConst.storeBuyAgain,
      label: 'Acheter encore',
      icon: Icons.replay_outlined,
      activeIcon: Icons.replay,
    ),
  );
}

void registerStoreAislesTab() {
  StoreTabRegistry.registerTab(
    StoreTabInfo(
      route: StoreRoutesConst.storeAisles,
      label: 'Rayons',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
    ),
  );
}
