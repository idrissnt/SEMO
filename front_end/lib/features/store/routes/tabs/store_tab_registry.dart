import 'package:semo/features/store/routes/tabs/store_tab_info.dart';

/// Registry for all tabs in the main navigation
/// This allows features to register their tabs without directly depending on each other
class StoreTabRegistry {
  /// Private list of registered tabs
  static final List<StoreTabInfo> _tabs = [];

  /// Register a new tab in the navigation
  static void registerTab(StoreTabInfo tab) {
    // Check if a tab with this route already exists
    final existingIndex = _tabs.indexWhere((t) => t.route == tab.route);

    // Replace existing tab or add new one
    if (existingIndex >= 0) {
      _tabs[existingIndex] = tab;
    } else {
      _tabs.add(tab);
    }
  }

  /// Get all registered tabs
  static List<StoreTabInfo> get tabs => List.unmodifiable(_tabs);

  /// Clear all registered tabs (useful for testing)
  static void clear() {
    _tabs.clear();
  }
}
