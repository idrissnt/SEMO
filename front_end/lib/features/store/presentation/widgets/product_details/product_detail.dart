import 'package:flutter/material.dart';
import 'package:semo/core/presentation/widgets/bottom_sheets/reusable_bottom_sheet.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

// Import component widgets
import 'package:semo/features/store/presentation/widgets/product_details/components/product_combo.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/product_image.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/product_info.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/related_products_list.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/top_bar.dart';

/// Shows a bottom sheet with product details
void showProductDetailBottomSheet({
  required BuildContext context,
  required CategoryProduct product,
  required String storeId,
  required List<CategoryProduct> relatedProducts,
}) {
  // Create a shared close function to ensure consistent behavior
  void closeSheet() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Use the reusable bottom sheet component
  showReusableBottomSheet(
    context: context,
    contentBuilder: (scrollController) => ProductDetailScreen(
      product: product,
      storeId: storeId,
      scrollController: scrollController,
      onClose: closeSheet,
      relatedProducts: relatedProducts,
    ),
  );
}

/// Screen that displays detailed information about a product
class ProductDetailScreen extends StatefulWidget {
  final CategoryProduct product;
  final String storeId;
  final VoidCallback onClose;
  final ScrollController scrollController;
  final List<CategoryProduct> relatedProducts;
  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.storeId,
    required this.onClose,
    required this.scrollController,
    required this.relatedProducts,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias, // This ensures content is clipped to the container's borders
      child: Stack(
        children: [
          // Scrollable content
          Scrollbar(
            controller: widget.scrollController,
            thickness: 4,
            radius: const Radius.circular(10),
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ProductImage(imageUrl: widget.product.imageUrl),

                  // Product name and description
                  ProductInfo(product: widget.product),

                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFEEEEEE),
                  ),

                  // Product combo section
                  ProductCombo(
                    mainProduct: widget.product,
                    relatedProducts: widget.relatedProducts,
                    storeId: widget.storeId,
                  ),
                  
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFEEEEEE),
                  ),

                  // Related products list
                  RelatedProductsList(
                    relatedProducts: widget.relatedProducts,
                    storeId: widget.storeId,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Top navigation bar with close and share buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(onClose: widget.onClose),
          ),
        ],
      ),
    );
  }

}
