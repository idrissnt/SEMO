import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/tab_registration/tab_info.dart';

/// Registry for all tabs in the main navigation
/// This allows features to register their tabs without directly depending on each other
class TabRegistry {
  /// Private list of registered tabs
  static final List<TabInfo> _tabs = [];

  /// Register a new tab in the navigation
  static void registerTab(TabInfo tab) {
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
  static List<TabInfo> get tabs => List.unmodifiable(_tabs);

  /// Clear all registered tabs (useful for testing)
  static void clear() {
    _tabs.clear();
  }
}
