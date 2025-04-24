import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Widget buildPaginationIndicators(
    BuildContext context, PageController pageController) {
  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SmoothPageIndicator(
        controller: pageController,
        count: 2,
        effect: const ExpandingDotsEffect(
          activeDotColor: Colors.blue,
          dotColor: Colors.grey,
          dotHeight: 12,
          dotWidth: 12,
          expansionFactor: 2,
          spacing: 4,
        ),
      ),
    ),
  );
}
