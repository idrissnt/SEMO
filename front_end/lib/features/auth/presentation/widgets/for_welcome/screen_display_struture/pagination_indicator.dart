import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';

Widget buildPaginationIndicators(
    BuildContext context, PageController pageController, int nbOfPages) {
  return Center(
    child: Container(
      padding: EdgeInsets.all(AppDimensionsWidth.xSmall),
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
          dotHeight: AppDimensionsHeight.small,
          dotWidth: AppDimensionsWidth.small,
          expansionFactor: 2,
          spacing: AppDimensionsWidth.xSmall,
        ),
      ),
    ),
  );
}
