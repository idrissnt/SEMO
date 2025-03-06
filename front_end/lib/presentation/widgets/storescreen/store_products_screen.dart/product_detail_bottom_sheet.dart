import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';

class ProductDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>, int)? onAddToCart;

  const ProductDetailBottomSheet({
    Key? key,
    required this.product,
    this.onAddToCart,
  }) : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> product,
      {Function(Map<String, dynamic>, int)? onAddToCart}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailBottomSheet(
        product: product,
        onAddToCart: onAddToCart,
      ),
    );
  }

  @override
  State<ProductDetailBottomSheet> createState() =>
      _ProductDetailBottomSheetState();
}

class _ProductDetailBottomSheetState extends State<ProductDetailBottomSheet> {
  final AppLogger _logger = AppLogger();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _logger.debug('Showing product detail for: ${widget.product['name']}');
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract product details
    final String name = widget.product['name']?.toString() ?? 'Unknown Product';
    final String imageUrl = widget.product['image_url']?.toString() ?? '';
    final double price = _extractPrice(widget.product);
    final String unit = widget.product['unit']?.toString() ?? '';
    final String description =
        widget.product['description']?.toString() ?? 'No description available';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Product image
          SizedBox(
            height: 200,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      _logger.warning('Failed to load product image: $error');
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 80),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 80),
                  ),
          ),
          // Product details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Price
                  Text(
                    '€${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nutritional info placeholder
                  const Text(
                    'Nutritional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calories: 100kcal per 100g'),
                        SizedBox(height: 4),
                        Text('Protein: 5g'),
                        SizedBox(height: 4),
                        Text('Carbohydrates: 20g'),
                        SizedBox(height: 4),
                        Text('Fat: 2g'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom bar with quantity and add button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),
                      Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Add to cart button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _logger
                          .debug('Adding $name to cart, quantity: $_quantity');
                      if (widget.onAddToCart != null) {
                        widget.onAddToCart!(widget.product, _quantity);
                      }
                      Navigator.of(context).pop();

                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $_quantity x $name to cart'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Add $_quantity to Cart - €${(price * _quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to extract price from product map
  double _extractPrice(Map<String, dynamic> product) {
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

    return 0.0; // Default price if not found
  }
}
