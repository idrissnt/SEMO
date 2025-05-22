import 'package:semo/features/store/routes/tabs/store_tab_registration.dart';

/// Registers all tabs (bottom navigation items) from all features
/// This should be called during app initialization
void registerStoreTabs() {
  // Register tabs in the order they should appear
  registerStoreTab();
  registerStoreAislesTab();
  registerStoreBuyAgainTab();
}
