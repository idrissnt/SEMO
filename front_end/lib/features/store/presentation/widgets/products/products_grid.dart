import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'product_card.dart';

/// Widget that displays a grid of products for a subcategory
class ProductsGrid extends StatelessWidget {
  /// The subcategory to display products for
  final AisleCategory category;

  /// Store ID for navigation
  final String storeId;

  /// Category ID for navigation
  final String aisleId;

  /// Creates a new products grid
  const ProductsGrid({
    Key? key,
    required this.category,
    required this.storeId,
    required this.aisleId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Title as a scrollable header
        SliverToBoxAdapter(
          child: _buildTitle(subcategoryName: category.name),
        ),

        // Products grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.80,
              crossAxisSpacing: 8,
              mainAxisSpacing: 4,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(
                  product: category.products[index],
                  relatedProducts: category.products,
                  storeId: storeId),
              childCount: category.products.length,
            ),
          ),
        ),
      ],
    );
  }

  // build Subcategory title
  Widget _buildTitle({required String subcategoryName}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Text(
        subcategoryName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimaryColor,
        ),
      ),
    );
  }
}
