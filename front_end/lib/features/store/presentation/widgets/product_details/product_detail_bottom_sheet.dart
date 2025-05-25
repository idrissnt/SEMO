import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_sheet_nav/bottom_sheet_navigator.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/widgets/product_details/product_detail.dart';
import 'package:semo/features/store/routes/bottom_sheet/product_detail/router_config.dart';
import 'package:semo/features/store/routes/bottom_sheet/product_detail/routes_constants.dart';

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
      initialRoute: ProductDetailRoutesConstants.root,
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
