import 'package:flutter/foundation.dart';

/// Controller that manages the selected tab in the store detail screen
class StoreTabController extends ChangeNotifier {
  /// The currently selected tab index
  int _selectedIndex;
  
  /// Creates a new store tab controller
  StoreTabController({int initialTab = 0}) : _selectedIndex = initialTab;
  
  /// Gets the currently selected tab index
  int get selectedIndex => _selectedIndex;
  
  /// Sets the selected tab index and notifies listeners
  void setTab(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
