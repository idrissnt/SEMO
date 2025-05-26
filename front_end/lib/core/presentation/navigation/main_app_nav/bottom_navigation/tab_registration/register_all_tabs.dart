import 'package:semo/features/community_shop/routes/community_shop_tab_registration.dart';
import 'package:semo/features/order/routes/order_tab_registration.dart';
import 'package:semo/features/message/routes/message_tab_registration.dart';

/// Registers all tabs (bottom navigation items) from all features
/// This should be called during app initialization
void registerAllTabs() {
  // Register tabs in the order they should appear
  registerOrderTab();
  registerCommunityShopTab();
  registerMessageTab();
}
