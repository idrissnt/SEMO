// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

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
    // Reduced app bar height to minimize white space
    final appBarHeight = isCollapsed
        ? context.responsiveItemSize(kToolbarHeight)
        : context.responsiveItemSize(kToolbarHeight * 1.9);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          elevation: isCollapsed ? context.cardElevation : 0,
          color: context.backgroundColor,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: appBarHeight,
              width: constraints.maxWidth,
              child: Stack(
                children: [
                  // Top row with location and icons - only visible when not collapsed
                  if (!isCollapsed)
                    Positioned(
                      top: context.xxs,
                      left: context.m,
                      right: context.m,
                      child: _buildTopRow(context),
                    ),

                  // Search bar with animated position
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    // Adjusted search bar position for reduced app bar height
                    top: isCollapsed
                        ? context.s
                        : context.responsiveItemSize(kToolbarHeight * 0.95),
                    left: context.m,
                    right: context.m,
                    height: context.buttonHeightMedium,
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
        context.iconMedium(
            icon: Icons.location_on, color: context.textPrimaryColor),
        SizedBox(width: context.xxs),
        SizedBox(
          width: context.responsiveItemSize(100),
          child: Text(
            '1226 UniverS of',
            style: context.appBarTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        context.iconMedium(
            icon: Icons.keyboard_arrow_down, color: context.textPrimaryColor),
      ],
    );
  }

  Widget _buildActionIcons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: context.iconMedium(
              icon: Icons.shopping_cart_outlined,
              color: context.textPrimaryColor),
          onPressed: () {},
          padding: EdgeInsets.all(context.xs),
        ),
        IconButton(
          icon: context.iconMedium(
              icon: Icons.notifications_none, color: context.textPrimaryColor),
          onPressed: () {},
          padding: EdgeInsets.all(context.xs),
        ),
        IconButton(
          icon: context.iconMedium(
              icon: Icons.person_outline, color: context.textPrimaryColor),
          onPressed: () {},
          padding: EdgeInsets.all(context.xs),
        ),
      ],
    );
  }

  Widget _buildSearchBarRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          // flex: 8,
          child: _buildSearchBar(context),
        ),
        if (isCollapsed)
          IconButton(
            icon: context.iconMedium(
                icon: Icons.person, color: context.textPrimaryColor),
            onPressed: () {},
            padding: EdgeInsets.all(context.xs),
          ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(context.borderRadiusXLarge),
      child: SizedBox(
        height: context.buttonHeightMedium,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: context.m),
              child: context.iconMedium(
                  icon: Icons.search, color: context.textSurfaceColor),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: context.appBarTitle.copyWith(
                    color: context.textSurfaceColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: context.s, horizontal: context.xs),
                  isDense: true,
                ),
                style: context.bodyMedium.copyWith(
                  color: context.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
