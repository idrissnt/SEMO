import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

/// A shimmer loading widget specifically for store brands
/// Displays a horizontal row of brand logo placeholders
class StoreBrandsShimmer extends StatelessWidget {
  const StoreBrandsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensionsWidth.medium,
          vertical: AppDimensionsHeight.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
            ),
            SizedBox(height: AppDimensionsHeight.medium),

            // Horizontal list of brand placeholders
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: AppDimensionsWidth.small),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.medium),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
