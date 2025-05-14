import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/constant/constants.dart';

/// A custom search bar widget that adapts its appearance based on scroll state
class SearchBarWidget extends StatelessWidget {
  final bool isScrolled;

  const SearchBarWidget({
    Key? key,
    required this.isScrolled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: OrderConstants.animationDuration,
      curve: Curves.easeInOut,
      height: OrderConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: AppColors.searchBarColor,
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
            child:
                const Icon(Icons.search, color: AppColors.iconColorFirstColor),
          ),
          SizedBox(width: AppDimensionsWidth.xSmall),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: OrderConstants.searchHintText,
                hintStyle: const TextStyle(color: AppColors.searchBarHintColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: AppDimensionsHeight.xSmall),
              ),
              style: TextStyle(fontSize: AppFontSize.medium),
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
