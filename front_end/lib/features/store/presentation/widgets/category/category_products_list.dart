import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/widgets/products/product_card.dart';
import 'package:semo/features/store/routes/route_config/store_routes_const.dart';

/// A horizontal scrollable list of products for a specific category
class CategoryProductsList extends StatelessWidget {
  /// The aisle containing products to display
  final StoreAisle aisle;

  /// The store brand
  final StoreBrand storeBrand;

  /// Creates a new category products list
  const CategoryProductsList({
    Key? key,
    required this.aisle,
    required this.storeBrand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with image and name
        _buildCategoryHeader(context),

        const SizedBox(height: 12),

        // Products list
        SizedBox(
          height: 210, // Fixed height for the product list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: aisle.categories.first.products.length,
            itemBuilder: (context, index) {
              final product = aisle.categories.first.products[index];
              return Container(
                width: 140, // Fixed width for each product card
                margin: const EdgeInsets.only(right: 12),
                child: ProductCard(product: product, storeId: ''),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the category header with image and name
  Widget _buildCategoryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Category image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              aisle.categories.first.imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 24),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Category name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  aisle.categories.first.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  aisle.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // View all button
          TextButton(
            onPressed: () {
              // Navigate to category detail
              context.goNamed(
                StoreRoutesConst.productsQuickViewName,
                pathParameters: {
                  'storeName': storeBrand.name,
                  'aisleName': aisle.name,
                  'categoryName': aisle.categories.first.name,
                },
                extra: storeBrand,
              );
            },
            child: const Text('View all'),
          ),
        ],
      ),
    );
  }
}
