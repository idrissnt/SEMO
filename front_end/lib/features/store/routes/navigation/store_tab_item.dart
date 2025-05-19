import 'package:flutter/material.dart';

/// Model for a tab item in the store bottom navigation
class StoreTabItem {
  /// Icon for the tab
  final IconData icon;

  /// Label for the tab
  final String label;

  /// Route suffix for the tab
  final String route;

  /// Creates a new store tab item
  const StoreTabItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
