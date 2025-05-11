import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/styles/company_and_store_theme.dart';
import 'package:semo/features/order/presentation/widgets/state_handler/home_store/loading_state_widget/all_shimmer/autocomplete_suggestions_shimmer.dart';
import 'package:semo/features/order/presentation/widgets/state_handler/home_store/loading_state_widget/all_shimmer/nearby_stores_shimmer.dart';
import 'package:semo/features/order/presentation/widgets/state_handler/home_store/loading_state_widget/all_shimmer/products_shimmer.dart';
import 'package:semo/features/order/presentation/widgets/state_handler/home_store/loading_state_widget/all_shimmer/search_results_shimmer.dart';
import 'package:semo/features/order/presentation/widgets/state_handler/home_store/loading_state_widget/all_shimmer/store_brands_shimmer.dart';

/// A reusable widget for displaying loading states
/// Provides consistent loading UI across the application
enum ShimmerType {
  none,
  storeBrands,
  nearbyStores,
  products,
  searchResults,
  autocompleteSuggestions,
}

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool useShimmer;
  final ShimmerType shimmerType;

  const LoadingStateWidget({
    Key? key,
    this.message,
    this.useShimmer = false,
    this.shimmerType = ShimmerType.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useShimmer) {
      return _buildShimmerLoading(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 4.r,
            backgroundColor: AppColors.secondary,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (message != null) ...[
            SizedBox(height: AppDimensionsHeight.medium),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.medium,
                color: AppColors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    // Return the appropriate shimmer widget based on the type
    switch (shimmerType) {
      case ShimmerType.storeBrands:
        return const StoreBrandsShimmer();

      case ShimmerType.nearbyStores:
        return const NearbyStoresShimmer();

      case ShimmerType.products:
        return const ProductsShimmer();

      case ShimmerType.searchResults:
        return const SearchResultsShimmer();

      case ShimmerType.autocompleteSuggestions:
        return const AutocompleteSuggestionsShimmer();

      case ShimmerType.none:
        // Default generic shimmer
        return Container(
          width: double.infinity,
          height: WelcomeDimensions.bigCardHeight,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          child: message != null
              ? Center(
                  child: Text(
                    message!,
                    style: TextStyle(
                      fontSize: AppFontSize.medium,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        );
    }
  }
}
