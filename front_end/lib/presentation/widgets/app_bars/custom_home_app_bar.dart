// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

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
    final size = MediaQuery.of(context).size;

    return Material(
      elevation: isCollapsed ? 2 : 0,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: isCollapsed ? kToolbarHeight : kToolbarHeight * 2,
          child: Stack(
            children: [
              // Top row with location and icons
              if (!isCollapsed)
                Positioned(
                  top: 8,
                  left: size.width * 0.04,
                  right: size.width * 0.04,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: size.width * 0.06,
                            color: Colors.black,
                          ),
                          SizedBox(width: size.width * 0.01),
                          SizedBox(
                            width: size.width * 0.3,
                            child: Text(
                              '1226 UniverS of',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: size.width * 0.035,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: size.width * 0.06,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_cart_outlined, size: 24),
                            onPressed: () {},
                            padding: EdgeInsets.all(8),
                            color: Colors.black87,
                          ),
                          IconButton(
                            icon: Icon(Icons.notifications_none, size: 24),
                            onPressed: () {},
                            padding: EdgeInsets.all(8),
                            color: Colors.black87,
                          ),
                          IconButton(
                            icon: Icon(Icons.person_outline, size: 24),
                            onPressed: () {},
                            padding: EdgeInsets.all(8),
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // Search bar with animated position
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                top: isCollapsed ? 8 : kToolbarHeight - 8,
                left: size.width * 0.04,
                right: isCollapsed ? size.width * 0.15 : size.width * 0.04,
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSearchBar(context, isCollapsed),
                    ),
                    if (isCollapsed)
                      IconButton(
                        icon: Icon(Icons.person_outline, size: 24),
                        onPressed: () {},
                        padding: EdgeInsets.all(8),
                        color: Colors.black87,
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

  Widget _buildSearchBar(BuildContext context, bool isCollapsed) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 48,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.search,
                size: 24,
                color: Colors.grey[700],
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  isDense: true,
                ),
                style: TextStyle(
                  fontSize: 16,
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
