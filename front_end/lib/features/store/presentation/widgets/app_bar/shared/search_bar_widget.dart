import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A custom search bar widget that can be used across the application
class SearchBarWidget extends StatelessWidget {
  /// Whether the search bar is in a scrolled state (for animations)
  final bool isScrolled;

  /// Hint text to display when the search field is empty
  final String hintText;

  /// Callback when the search query changes
  final Function(String)? onQueryChanged;

  /// Minimum query length before triggering the onQueryChanged callback
  final int minQueryLength;

  /// Height of the search bar
  final double height;

  /// Background color of the search bar
  final Color? backgroundColor;

  /// Border radius of the search bar
  final double borderRadius;

  /// Icon to show in the search bar
  final IconData icon;

  /// Size of the search icon
  final double iconSize;

  /// Horizontal padding inside the search bar
  final double horizontalPadding;

  /// Text controller for the search field
  final TextEditingController? controller;

  /// Creates a new search bar widget
  const SearchBarWidget({
    Key? key,
    this.isScrolled = false,
    this.hintText = 'Rechercher',
    this.onQueryChanged,
    this.minQueryLength = 3,
    this.height = 40,
    this.backgroundColor,
    this.borderRadius = 20,
    this.icon = Icons.search,
    this.iconSize = 20,
    this.horizontalPadding = 12,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Icon(
              icon,
              color: AppColors.iconColorFirstColor,
              size: iconSize,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.searchBarHintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: TextStyle(fontSize: AppFontSize.medium),
              onChanged: (query) {
                if (onQueryChanged != null && query.length >= minQueryLength) {
                  onQueryChanged!(query);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
