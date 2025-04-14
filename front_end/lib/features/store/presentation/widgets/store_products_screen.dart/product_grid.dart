import 'package:flutter/material.dart';
import '../../../../../core/utils/logger.dart';
import 'product_detail_bottom_sheet.dart';

class ProductGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>)? onAddToCart;
  final AppLogger _logger = AppLogger();

  ProductGrid({
    Key? key,
    required this.products,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logger.debug('Building ProductGrid with ${products.length} products');

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No products available in this category',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    // Extract product details
    final String name = product['name']?.toString() ?? 'Unknown Product';
    final String imageUrl = product['image_url']?.toString() ?? '';
    final double price = _extractPrice(product);
    final String unit = product['unit']?.toString() ?? '';
    final bool isOnSale = product['is_on_sale'] == true;
    final double? originalPrice =
        isOnSale ? (price * 1.2) : null; // Simulate original price

    _logger.debug('Building product card for: $name');
    _logger.debug('- Price: €${price.toStringAsFixed(2)}');
    _logger.debug('- Unit: $unit');
    _logger.debug('- Image URL: $imageUrl');

    return GestureDetector(
      onTap: () {
        _logger.debug('Product card tapped: $name');
        ProductDetailBottomSheet.show(
          context,
          product,
          onAddToCart: (product, quantity) {
            _logger.debug(
                'Adding $quantity x ${product['name']} to cart from detail sheet');
            if (onAddToCart != null) {
              onAddToCart!(product);
            }
          },
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              _logger.warning(
                                  'Failed to load product image: $error');
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported,
                                    size: 40),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child:
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                  ),
                ),
                // Sale badge
                if (isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Unit/Weight
                    if (unit.isNotEmpty)
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Price section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isOnSale && originalPrice != null)
                              Text(
                                '€${originalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            Text(
                              '€${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isOnSale ? Colors.red : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        // Add button
                        GestureDetector(
                          onTap: () {
                            _logger
                                .debug('Add to cart button tapped for: $name');
                            if (onAddToCart != null) {
                              onAddToCart!(product);
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to extract price from product map
  double _extractPrice(Map<String, dynamic> product) {
    _logger.debug('Extracting price from product: ${product['name']}');

    // Try to get price from different possible fields
    if (product.containsKey('price')) {
      final price = product['price'];
      if (price is num) return price.toDouble();
      if (price is String) return double.tryParse(price) ?? 0.0;
    }

    // Try price_range if available
    if (product.containsKey('price_range')) {
      final priceRange = product['price_range'];
      if (priceRange is List && priceRange.isNotEmpty) {
        final firstPrice = priceRange.first;
        if (firstPrice is num) return firstPrice.toDouble();
        if (firstPrice is String) return double.tryParse(firstPrice) ?? 0.0;
      }
    }

    _logger.warning('No valid price found for product: ${product['name']}');
    return 0.0; // Default price if not found
  }
}
