import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/routes/navigation/store_tab_item.dart';

/// Bottom navigation bar for the store detail screen
class StoreBottomNavBar extends StatelessWidget {
  /// The currently selected tab index
  final int selectedIndex;

  /// Callback when a tab is tapped
  final Function(int) onTap;

  /// List of tab items to display
  final List<StoreTabItem> tabs;

  /// Creates a new store bottom navigation bar
  const StoreBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      items: tabs
          .map((tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ))
          .toList(),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
    );
  }
}
