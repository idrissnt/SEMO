import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A shimmer loading widget specifically for nearby stores
/// Displays a vertical list of store card placeholders with location indicators
class NearbyStoresShimmer extends StatelessWidget {
  const NearbyStoresShimmer({Key? key}) : super(key: key);

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
            // Section title placeholder
            Container(
              width: 180,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
            ),
            SizedBox(height: AppDimensionsHeight.medium),

            // Store cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppDimensionsHeight.small),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    child: Row(
                      children: [
                        // Store image placeholder
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

                        // Store details
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(AppDimensionsWidth.small),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Store name placeholder
                                Container(
                                  width: double.infinity,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        AppBorderRadius.small),
                                  ),
                                ),

                                // Store address placeholder
                                Container(
                                  width: double.infinity,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        AppBorderRadius.small),
                                  ),
                                ),

                                // Distance placeholder
                                Container(
                                  width: 80,
                                  height: 14,
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
