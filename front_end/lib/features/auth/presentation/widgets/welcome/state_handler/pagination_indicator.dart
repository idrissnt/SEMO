import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

Widget buildPaginationIndicators(
    BuildContext context, PageController pageController, int nbOfPages) {
  return Center(
    child: Container(
      padding: EdgeInsets.symmetric(
          vertical: context.sWidth, horizontal: context.mediumHeight),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(context.borderRadiusLargeWidth),
      ),
      child: SmoothPageIndicator(
        controller: pageController,
        count: nbOfPages,
        effect: ExpandingDotsEffect(
          activeDotColor: context.primaryColor,
          dotColor: context.secondaryVariantColor,
          dotHeight: context.mediumHeight,
          dotWidth: context.mWidth,
          expansionFactor: 2,
          spacing: context.xsWidth,
        ),
      ),
    ),
  );
}
