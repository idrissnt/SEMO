// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:front_end/core/extensions/responsive_extension.dart';
import 'package:front_end/core/utils/responsive_utils.dart';

class CustomHomeAppBar extends StatelessWidget {
  final bool isCollapsed;
  final double scrolledRatio;

  const CustomHomeAppBar({
    Key? key,
    required this.isCollapsed,
    required this.scrolledRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    // Responsive height calculation
    final appBarHeight = deviceType == ResponsiveUtils.getDeviceType(context)
        ? (isCollapsed ? kToolbarHeight : kToolbarHeight * 2)
        : (isCollapsed ? kToolbarHeight * 1.2 : kToolbarHeight * 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          elevation: isCollapsed ? 2 : 0,
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: appBarHeight,
              width: constraints.maxWidth,
              child: Stack(
                children: [
                  // Top row with location and icons
                  if (!isCollapsed)
                    Positioned(
                      top: 1,
                      left: context.responsiveSize(0.04),
                      right: context.responsiveSize(0.04),
                      child: _buildTopRow(context),
                    ),

                  // Search bar with animated position
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    top: isCollapsed
                        ? 1
                        : (deviceType == ResponsiveUtils.getDeviceType(context)
                            ? kToolbarHeight
                            : kToolbarHeight * 1.2),
                    left: context.responsiveSize(0.04),
                    right: context.responsiveSize(0.04),
                    height: 48,
                    child: _buildSearchBarRow(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLocationWidget(context),
        _buildActionIcons(context),
      ],
    );
  }

  Widget _buildLocationWidget(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: context.responsiveSize(0.06),
          color: Colors.black,
        ),
        SizedBox(width: context.responsiveSize(0.01)),
        SizedBox(
          width: context.responsiveSize(0.3),
          child: Text(
            '1226 UniverS of',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: context.responsiveSize(0.035),
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down,
          size: context.responsiveSize(0.06),
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _buildActionIcons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(Icons.shopping_cart_outlined),
        _buildIconButton(Icons.notifications_none),
        _buildIconButton(Icons.person_outline),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, size: 24),
      onPressed: () {},
      padding: EdgeInsets.all(8),
      color: Colors.black87,
    );
  }

  Widget _buildSearchBarRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 8,
          child: _buildSearchBar(context),
        ),
        if (isCollapsed) _buildIconButton(Icons.person_outline),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.search,
                size: context.responsiveSize(0.05),
                color: Colors.grey[700],
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontSize: context.responsiveSize(0.04),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  isDense: true,
                ),
                style: TextStyle(
                  fontSize: context.responsiveSize(0.04),
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
