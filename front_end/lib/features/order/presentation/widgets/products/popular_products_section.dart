import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/order/presentation/widgets/products/product_card.dart';

/// A section that displays popular products for a specific store
///
/// This widget is used in the OrderScreen to show popular products
/// for each store, encouraging users to place orders.
class PopularProductsSection extends StatelessWidget {
  final String sectionTitle;

  /// The name of the store
  final String storeName;

  /// The URL of the store logo
  final String storeLogo;

  /// The list of products to display
  final List<Map<String, dynamic>> products;

  /// Callback when a product is tapped
  final Function(Map<String, dynamic>) onProductTap;

  /// Callback when a product is added to cart
  final Function(Map<String, dynamic>) onAddToCart;

  /// Callback when "See all" is tapped
  final VoidCallback onSeeAllTap;

  /// Logger instance
  final AppLogger _logger = AppLogger();

  PopularProductsSection({
    Key? key,
    required this.sectionTitle,
    required this.storeName,
    required this.storeLogo,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onSeeAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        _buildProductsList(),
      ],
    );
  }

  /// Builds the section header with store logo, name, and "See all" button
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4, top: 8, bottom: 8),
      child: Row(
        children: [
          // Store logo
          _buildStoreLogo(),
          const SizedBox(width: 8),
          // Section title with store name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chez $storeName',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // See all button
          TextButton(
            onPressed: () {
              _logger.info('Navigating to see all products for $storeName');
              onSeeAllTap();
            },
            child: const Row(
              children: [
                Text('Voir tout'),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the store logo with error handling
  Widget _buildStoreLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        shape: BoxShape.circle,
        image: storeLogo.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(storeLogo),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  _logger.error('Error loading store logo: $exception');
                },
              )
            : null,
      ),
      child: storeLogo.isEmpty
          ? const Icon(Icons.store, size: 16, color: Colors.grey)
          : null,
    );
  }

  /// Builds the horizontal list of product cards
  Widget _buildProductsList() {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            name: product['name'],
            imageUrl: product['imageUrl'],
            productPrice: product['productPrice'],
            productUnit: product['productUnit'],
            pricePerUnit: product['pricePerUnit'],
            baseUnit: product['baseUnit'],
            onTap: () {
              _logger.info('Product tapped: ${product['name']}');
              onProductTap(product);
            },
            onAddToCart: () {
              _logger.info('Add to cart: ${product['name']}');
              onAddToCart(product);
            },
          );
        },
      ),
    );
  }
}
