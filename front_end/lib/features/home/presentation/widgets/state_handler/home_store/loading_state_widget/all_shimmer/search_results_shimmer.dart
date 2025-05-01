import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A shimmer loading widget specifically for search results
/// Displays a list of search result placeholders with mixed layouts
class SearchResultsShimmer extends StatelessWidget {
  const SearchResultsShimmer({Key? key}) : super(key: key);

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
            // Search query placeholder
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
            ),
            SizedBox(height: AppDimensionsHeight.small),

            // Results count placeholder
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
            ),
            SizedBox(height: AppDimensionsHeight.medium),

            // Search result items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppDimensionsHeight.small),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    child: Row(
                      children: [
                        // Product image placeholder
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppBorderRadius.medium),
                              bottomLeft:
                                  Radius.circular(AppBorderRadius.medium),
                            ),
                          ),
                        ),

                        // Product details
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensionsWidth.small),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Product name placeholder
                                Container(
                                  width: double.infinity,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        AppBorderRadius.small),
                                  ),
                                ),

                                // Product description placeholder
                                Container(
                                  width: double.infinity,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        AppBorderRadius.small),
                                  ),
                                ),

                                // Price placeholder
                                Container(
                                  width: 80,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        AppBorderRadius.small),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
