import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/core/presentation/screens/image_viewer_screen.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/bottom_sheets/product_details/bottom_sheet_content.dart';
import 'package:semo/features/store/routes/bottom_sheet/product_detail/routes_constants.dart';

/// This class is responsible for creating the routes for the product detail bottom sheet navigator.
/// It follows the single responsibility principle by focusing only on route configuration.
class ProductDetailRouterConfig {
  /// Creates the routes for the product detail bottom sheet navigator
  ///
  /// [initialPage] is the initial page to display
  /// [storeId] is the ID of the store
  /// [relatedProducts] is the list of related products
  /// [scrollController] is the scroll controller for the bottom sheet
  static List<RouteBase> createRoutes({
    required Widget initialPage,
    required String storeId,
    required List<CategoryProduct> relatedProducts,
    ScrollController? scrollController,
  }) {
    return [
      // Initial product route
      GoRoute(
        path: BottomSheetProductDetailRoutesConstants.root,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: initialPage,
          name: 'ProductDetail',
        ),
      ),
      // Related product route with product ID parameter
      GoRoute(
        path: BottomSheetProductDetailRoutesConstants.relatedProduct,
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          // Find the product in the related products list
          final product = relatedProducts.firstWhere(
            (p) => p.id == productId,
            orElse: () => relatedProducts.first,
          );

          return buildPageWithTransition(
            context: context,
            state: state,
            child: ProductDetailScreen(
              product: product,
              storeId: storeId,
              relatedProducts: relatedProducts,
              scrollController: scrollController ?? ScrollController(),
              onClose: () => context.pop(),
              isBackButton: true,
            ),
            name: 'RelatedProduct',
          );
        },
      ),
      // Image viewer route with image URL and hero tag parameters
      GoRoute(
        name: BottomSheetProductDetailRoutesConstants.name,
        path: BottomSheetProductDetailRoutesConstants.imageViewer,
        pageBuilder: (context, state) {
          final String imageUrl;
          imageUrl = (state.extra as Map)['imageUrl'] as String;

          return buildPageWithTransition(
            context: context,
            state: state,
            child: ImageViewerScreen(
              imageUrl: imageUrl,
              heroTag: 'product_image_$imageUrl',
            ),
            name: BottomSheetProductDetailRoutesConstants.name,
          );
        },
      ),
    ];
  }

  // Private constructor to prevent instantiation
  ProductDetailRouterConfig._();
}
