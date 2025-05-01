import 'package:flutter/material.dart';

/// Represents a tab in the main navigation
/// a tab represents each item in the bottom navigation bar

class TabInfo {
  /// The route path for this tab
  final String route;

  /// The display label for this tab
  final String label;

  /// The icon to display when this tab is not selected
  final IconData icon;

  /// The icon to display when this tab is selected
  final IconData activeIcon;

  /// The screen widget to display for this tab
  final Widget screen;

  const TabInfo({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
  });
}
