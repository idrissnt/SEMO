import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/constant/constants.dart';

/// A custom search bar widget that adapts its appearance based on scroll state
class SearchBarWidget extends StatelessWidget {
  final bool isScrolled;
  final Color? searchBarColor;
  final Color? iconColor;
  final Color? hintColor;
  final String? hintText;
  final TextEditingController? searchController;

  const SearchBarWidget({
    Key? key,
    required this.isScrolled,
    this.searchBarColor,
    this.iconColor,
    this.hintColor,
    this.hintText,
    this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: OrderConstants.animationDuration,
      curve: Curves.easeInOut,
      height: OrderConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: searchBarColor ?? AppColors.searchBarColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppDimensionsWidth.medium),
      // Animate width changes
      width: isScrolled
          ? OrderConstants.searchBarWidth
          : OrderConstants.searchBarWidth,
      // No margin to avoid overflow
      child: Row(
        children: [
          // Animated icon
          AnimatedContainer(
            duration: OrderConstants.animationDuration,
            curve: Curves.easeInOut,
            padding: EdgeInsets.zero,
            child: Icon(Icons.search,
                color: iconColor ?? AppColors.iconColorFirstColor),
          ),
          SizedBox(width: AppDimensionsWidth.xSmall),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: hintText ?? OrderConstants.searchHintText,
                hintStyle:
                    TextStyle(color: hintColor ?? AppColors.searchBarHintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: AppDimensionsHeight.xSmall),
              ),
              style: TextStyle(
                  fontSize: AppFontSize.medium,
                  color: iconColor ?? AppColors.iconColorFirstColor),
              onChanged: (query) {
                if (query.length >= OrderConstants.queryLength) {
                  // Handle search query
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
