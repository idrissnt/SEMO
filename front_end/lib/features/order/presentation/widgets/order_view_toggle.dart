import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Widget buildPaginationIndicators(
    BuildContext context, PageController pageController, int nbOfPages) {
  return Center(
    child: Container(
      padding: EdgeInsets.all(AppDimensionsWidth.xxSmall),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
      ),
      child: SmoothPageIndicator(
        controller: pageController,
        count: nbOfPages,
        effect: ExpandingDotsEffect(
          activeDotColor: AppColors.primary,
          dotColor: AppColors.thirdColor,
          dotHeight: AppDimensionsHeight.xSmall,
          dotWidth: AppDimensionsWidth.xSmall,
          expansionFactor: 2,
          spacing: AppDimensionsWidth.xSmall,
        ),
      ),
    ),
  );
}
