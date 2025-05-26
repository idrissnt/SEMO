import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/bottom_sheets/product_details/navigator.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/bottom_and_top_bar/bottom_bar.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/bottom_and_top_bar/top_bar.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/related_products/product_combo.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/product_info/product_image.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/product_info/product_info.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/related_products/related_products_list.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/related_products/product_replacement.dart';
import 'package:semo/features/store/presentation/widgets/product_details/utils/section_divider.dart';
import 'package:semo/features/store/presentation/widgets/product_details/utils/text_informative.dart';
import 'package:flutter/material.dart';

/// Screen that displays detailed information about a product
class ProductDetailScreen extends StatefulWidget {
  final CategoryProduct product;
  final String storeId;
  final VoidCallback onClose;
  final ScrollController scrollController;
  final List<CategoryProduct> relatedProducts;
  final bool isBackButton;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.storeId,
    required this.onClose,
    required this.scrollController,
    required this.relatedProducts,
    this.isBackButton = false,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final hasBeenAddedToCart = false;
  int quantity = 1;
  bool _showProductNameInAppBar = false;
  final _imageKey = GlobalKey();

  void _handleQuantityChanged(int newQuantity) {
    setState(() {
      quantity = newQuantity;
    });
  }

  void _handleAddToCart() {
    // Implement add to cart functionality
    logger
        .debug('Added ${widget.product.name} to cart with quantity: $quantity');
  }

  // Check if the image is visible in the viewport
  void _checkImageVisibility() {
    if (_imageKey.currentContext == null) return;

    final RenderBox box =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    // If the top of the image is above the top of the screen by more than its height,
    // consider it not visible
    final imageHeight = box.size.height;
    final isVisible = position.dy > -imageHeight / 2;

    if (_showProductNameInAppBar != !isVisible) {
      setState(() {
        _showProductNameInAppBar = !isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the height of the bottom bar for padding
    const bottomBarHeight = 80.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip
          .antiAlias, // This ensures content is clipped to the container's borders
      child: Stack(
        children: [
          // Scrollable content
          Scrollbar(
            controller: widget.scrollController,
            thickness: 4,
            radius: const Radius.circular(10),
            thumbVisibility: true,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollUpdateNotification) {
                  _checkImageVisibility();
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image with key for visibility tracking
                    ProductImage(
                      key: _imageKey,
                      imageUrl: widget.product.imageUrl,
                    ),

                    // Product name and description
                    ProductInfo(product: widget.product),

                    divider(),

                    if (hasBeenAddedToCart)
                      // Product replacement section
                      ProductReplacementSection(
                        routeNameAddNote: 'add_note',
                        onTapAddNote: () => {},
                        routeNameAddReplacement: 'add_replacement',
                        onTapAddReplacement: () => {},
                      ),
                    divider(),
                    // Product combo section
                    ProductCombo(
                      mainProduct: widget.product,
                      relatedProducts: widget.relatedProducts,
                      storeId: widget.storeId,
                    ),

                    divider(),

                    // Related products list
                    RelatedProductsList(
                      relatedProducts: widget.relatedProducts,
                      storeId: widget.storeId,
                    ),

                    divider(),
                    textInformative(),

                    // Add extra space at the bottom to prevent content from being hidden behind the bottom bar
                    const SizedBox(height: bottomBarHeight + 16),
                  ],
                ),
              ),
            ),
          ),

          // Top navigation bar with close/back and share buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopBar(
              onClose: widget.onClose,
              productName: widget.product.name,
              showProductName: _showProductNameInAppBar,
              isBackButton: widget.isBackButton,
              storeId: widget.storeId,
              productId: widget.product.id,
            ),
          ),

          // Fixed bottom bar with quantity controller and add to cart button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomBar(
              quantity: quantity,
              onQuantityChanged: _handleQuantityChanged,
              onAddToCart: _handleAddToCart,
              productPrice: widget.product.price.toString(),
            ),
          ),
        ],
      ),
    );
  }
}
