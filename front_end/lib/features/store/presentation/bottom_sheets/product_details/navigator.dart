import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_sheet_nav/bottom_sheet_navigator.dart';
import 'package:semo/core/presentation/widgets/bottom_sheets/reusable_bottom_sheet.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/bottom_sheets/product_details/bottom_sheet_content.dart';

// Import component widgets

import 'package:semo/features/store/routes/bottom_sheet/product_detail/router_config.dart';
import 'package:semo/features/store/routes/bottom_sheet/product_detail/routes_constants.dart';

final logger = AppLogger();

/// Shows a bottom sheet with product details that supports navigation
void showProductDetailBottomSheet({
  required BuildContext context,
  required CategoryProduct product,
  required String storeId,
  required List<CategoryProduct> relatedProducts,
}) {
  // Use the reusable bottom sheet component with navigator
  showReusableBottomSheet(
    context: context,
    contentBuilder: (scrollController) => ProductDetailBottomSheetWithNavigator(
      initialProduct: product,
      storeId: storeId,
      relatedProducts: relatedProducts,
      scrollController: scrollController,
    ),
  );
}

/// A bottom sheet that contains a router for product details
class ProductDetailBottomSheetWithNavigator extends StatefulWidget {
  final CategoryProduct initialProduct;
  final String storeId;
  final List<CategoryProduct> relatedProducts;
  final ScrollController scrollController;

  const ProductDetailBottomSheetWithNavigator({
    Key? key,
    required this.initialProduct,
    required this.storeId,
    required this.relatedProducts,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<ProductDetailBottomSheetWithNavigator> createState() =>
      _ProductDetailBottomSheetWithNavigatorState();
}

class _ProductDetailBottomSheetWithNavigatorState
    extends State<ProductDetailBottomSheetWithNavigator> {
  // Key for the bottom sheet navigator
  final _navigatorKey = GlobalKey<BottomSheetNavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BottomSheetNavigator(
      key: _navigatorKey,
      initialPage: _buildProductDetailPage(),
      initialRoute: BottomSheetProductDetailRoutesConstants.root,
      routeCreator: (initialPage) => ProductDetailRouterConfig.createRoutes(
        initialPage: initialPage,
        storeId: widget.storeId,
        relatedProducts: widget.relatedProducts,
        scrollController: widget.scrollController,
      ),
      scrollController: widget.scrollController,
    );
  }

  // Build the initial product detail page directly
  Widget _buildProductDetailPage() {
    return ProductDetailScreen(
      product: widget.initialProduct,
      storeId: widget.storeId,
      relatedProducts: widget.relatedProducts,
      scrollController: widget.scrollController,
      onClose: () => Navigator.of(context, rootNavigator: true).pop(),
      isBackButton: false,
    );
  }
}
