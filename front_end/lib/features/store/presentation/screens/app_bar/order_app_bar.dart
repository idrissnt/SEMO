import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/location_section.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/search_bar_widget.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/action_icons.dart';

/// A collapsible app bar for the home screen that changes appearance on scroll
class OrderAppBar extends StatelessWidget {
  final bool isScrolled;
  final ScrollController scrollController;

  /// Callback for when the location section is tapped
  final VoidCallback onLocationTap;

  const OrderAppBar({
    Key? key,
    required this.isScrolled,
    required this.scrollController,
    required this.onLocationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isScrolled ? 60 : 110,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isScrolled
            ? [
                const BoxShadow(
                  color: AppColors.appBarShadowColor,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ]
            : null,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          color: Colors.white,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location row with animated opacity
              AnimatedOpacity(
                opacity: isScrolled ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isScrolled ? 0 : 50,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensionsWidth.medium),
                  child: isScrolled
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            // Location section
                            LocationSection(onLocationTap: onLocationTap),
                            const Spacer(),
                            // Action icons
                            const ActionIcons(),
                          ],
                        ),
                ),
              ),
              // Add spacing only when showing the location row
              if (!isScrolled) const SizedBox(height: 8),
              // Search bar row - with cart icon when scrolled
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppDimensionsWidth.medium),
                child: Row(
                  children: [
                    // Search bar takes most of the space
                    Expanded(
                      child: SearchBarWidget(isScrolled: isScrolled),
                    ),
                    // Animated cart icon with fade in/out
                    AnimatedOpacity(
                      opacity: isScrolled ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isScrolled ? null : 0,
                        padding: EdgeInsets.only(left: isScrolled ? 4 : 0),
                        child: isScrolled
                            ? const CartProfileIcon()
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
