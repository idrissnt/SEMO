import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Feature imports
import 'package:semo/features/store/presentation/widgets/app_bar/shared/search_bar_widget.dart';

class AppBarBuilder {
  //
  /// Builds the app bar with title and actions
  ///
  /// Parameters:
  /// - context: The build context
  /// - route: The route to navigate to when back button is pressed
  /// - showLeadingIcon: Whether to show the leading icon (back button)
  /// - hintText: The hint text for the search bar
  /// - onQueryChanged: Callback when search query changes
  /// - disableBackButton: If true, explicitly disables the back button by setting automaticallyImplyLeading to false
  PreferredSizeWidget buildAppBar(
    BuildContext context,
    String route,
    bool showLeadingIcon,
    String hintText,
    Function(String) onQueryChanged, {
    bool disableBackButton = false,
  }) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading:
          !disableBackButton, // Disable back button if requested
      titleSpacing: showLeadingIcon
          ? 0.0
          : 0.0, // Adjust spacing based on whether leading icon is shown
      title: Padding(
        // Apply different padding when leading icon is shown vs. not shown
        padding: EdgeInsets.only(
          left: showLeadingIcon ? 0.0 : 16.0,
          right: 16.0,
        ),
        child: _buildSearchBar(hintText, onQueryChanged),
      ),
      leading: (showLeadingIcon && !disableBackButton)
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go(route),
            )
          : null,
    );
  }

  /// Builds the search bar using the reusable SearchBarWidget component
  Widget _buildSearchBar(String hintText, Function(String) onQueryChanged) {
    return SearchBarWidget(
      hintText: hintText,
      onQueryChanged: onQueryChanged,
      minQueryLength: 3,
      backgroundColor: Colors.grey.shade200,
    );
  }
}
