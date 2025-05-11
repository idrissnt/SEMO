import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A shimmer loading widget specifically for autocomplete suggestions
/// Displays a dropdown-like list of suggestion placeholders
class AutocompleteSuggestionsShimmer extends StatelessWidget {
  const AutocompleteSuggestionsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          boxShadow: const [
            BoxShadow(
              color: AppColors.iconColorFirstColor,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppDimensionsWidth.small),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimensionsHeight.small,
                  horizontal: AppDimensionsWidth.small,
                ),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensionsWidth.small,
                    vertical: AppDimensionsHeight.small,
                  ),
                  child: Row(
                    children: [
                      // Search icon placeholder
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: AppDimensionsWidth.small),

                      // Suggestion text placeholder
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.small),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
