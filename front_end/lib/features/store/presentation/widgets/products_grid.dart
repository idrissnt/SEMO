import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/domain/entities/categories/store_category.dart';
import 'package:semo/features/store/presentation/widgets/product_card.dart';

/// Widget that displays a grid of products for a subcategory
class ProductsGrid extends StatelessWidget {
  /// The subcategory to display products for
  final StoreSubcategory subcategory;

  /// Store ID for navigation
  final String storeId;

  /// Category ID for navigation
  final String categoryId;

  /// Creates a new products grid
  const ProductsGrid({
    Key? key,
    required this.subcategory,
    required this.storeId,
    required this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(subcategoryName: subcategory.name),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.80, // Reduced to allow more vertical space
              crossAxisSpacing: 8,
              mainAxisSpacing: 4, // Small spacing between rows
            ),
            itemCount: subcategory.products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: subcategory.products[index]);
            },
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
