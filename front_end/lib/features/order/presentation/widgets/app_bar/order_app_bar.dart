import 'package:flutter/material.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/location_section.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/search_bar_widget.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/action_icons.dart';

/// A collapsible app bar for the home screen that changes appearance on scroll
class OrderAppBar extends StatelessWidget {
  final bool isScrolled;

  /// Callback for when the location section is tapped
  final VoidCallback onLocationTap;

  final double scrollProgress;

  const OrderAppBar({
    Key? key,
    required this.isScrolled,
    required this.onLocationTap,
    required this.scrollProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // Calculate height based on scroll progress for smooth transition
    final appBarHeight = statusBarHeight + 110.0 - (60.0 * scrollProgress);

    // Calculate search bar position and width based on scroll progress
    final searchBarRightPosition = 16.0 + (90.0 * scrollProgress);
    const searchBarLeftPosition = 16.0;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: appBarHeight,
        child: Stack(
          children: [
            //
            // Location section
            Positioned(
              top: 12,
              left: 16,
              child: Opacity(
                opacity: 1.0 - (scrollProgress * 2).clamp(0.0, 1.0),
                child: LocationSection(onLocationTap: onLocationTap),
              ),
            ),
            // Action icons
            Positioned(
              top: 12,
              right: 16,
              child: ActionIcons(scrollProgress: scrollProgress),
            ),

            // Search bar takes most of the space
            Positioned(
              bottom: 0,
              left: searchBarLeftPosition,
              right: searchBarRightPosition,
              child: SearchBarWidget(isScrolled: isScrolled),
            ),
          ],
        ),
      ),
    );
  }
}
