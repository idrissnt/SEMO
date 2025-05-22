import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/widgets/products/product_detail_bottom_sheet.dart';
import 'package:semo/features/store/presentation/widgets/products/utils/quantity_controller.dart';
import 'package:semo/features/store/presentation/widgets/store_buy_again_tab/add_to_cart_scaffold.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';

/// Screen that displays a list of products in a vertical scrollable way
class ProductListScreen extends StatefulWidget {
  /// The list of products to display
  final List<CategoryProduct> products;

  /// The store ID
  final String storeId;

  /// Creates a new product list screen
  const ProductListScreen({
    Key? key,
    required this.products,
    required this.storeId,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Map to track quantity for each product
  final Map<String, int> productQuantities = {};

  @override
  Widget build(BuildContext context) {
    return AddToCartScaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Articles (${widget.products.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          buildIcon(
            containerSize: 40,
            scrollProgress: 0,
            icon: Icons.shopping_cart,
            iconColor: Colors.white,
            backgroundColor: Colors.green,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(CategoryProduct product) {
    // Get quantity for this product, default to 1 if not set
    final quantity = productQuantities[product.id] ?? 1;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main product card
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: InkWell(
            onTap: () {
              // Navigate to product detail using GoRouter
              showProductDetailBottomSheet(context, product);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product image with info icon
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Product image
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          child: SizedBox(
                            width: 100,
                            height: 120,
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 40),
                              ),
                            ),
                          ),
                        ),

                        // Info icon
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Product details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Price
                            Row(
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (product.productUnit.isNotEmpty)
                                  Text(
                                    product.productUnit,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 17,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Price per unit
                            Text(
                              '\$${product.pricePerUnit.toStringAsFixed(2)}/${product.unit}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Add to cart button
        Positioned(
          top: 16,
          right: 4,
          child: ProductQuantityController(
            backgroundColor: Colors.grey[300],
            iconColor: Colors.black,
            width: 120,
            height: 32,
            iconSize: 28,
            initialQuantity: quantity,
            onQuantityChanged: (newQuantity) {
              setState(() {
                productQuantities[product.id] = newQuantity;
              });
            },
          ),
        ),

        // Quantity indicator at bottom outside the card
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 55,
            padding:
                const EdgeInsets.only(right: 8, left: 16, top: 4, bottom: 4),
            decoration: const BoxDecoration(
              // color: Color(0xFFFFDE21),
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(0),
              ),
            ),
            child: Text(
              'x $quantity', // This would be dynamic based on cart quantity
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
