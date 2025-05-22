import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Build a related product item
Widget buildRelatedProductItem(
    CategoryProduct product, Function(CategoryProduct) onProductTap) {
  return InkWell(
    onTap: () => onProductTap(product),
    child: Container(
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Product image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 24),
                ),
              ),
            ),
          ),

          // Add button
          Container(
            width: double.infinity,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: const Icon(Icons.add, size: 20),
          ),
        ],
      ),
    ),
  );
}

/// Build the related products section
Widget buildRelatedProductsSection(
    List<CategoryProduct> relatedProducts, Function(CategoryProduct) onProductTap) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Frequently bought together',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),

      // Horizontal list of related products
      SizedBox(
        height: 120,
        child: relatedProducts.isEmpty
            ? const Center(child: Text('No related products found'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: relatedProducts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: buildRelatedProductItem(
                        relatedProducts[index], onProductTap),
                  );
                },
              ),
      ),
    ],
  );
}

/// Generate mock related products for demonstration
List<CategoryProduct> getMockRelatedProducts(
    CategoryProduct currentProduct, bool isNestedProduct) {
  // Don't show the current product in related products
  // In a real app, this would come from an API call or repository

  // Create 3 mock products with variations of the current product
  final List<CategoryProduct> mockProducts = [];

  // Only create related products if we're not already showing a related product
  // This prevents infinite nesting of related products
  if (!isNestedProduct) {
    // Create variations of the current product with different IDs and slightly different names/prices
    for (int i = 1; i <= 3; i++) {
      mockProducts.add(
        CategoryProduct(
          id: '${currentProduct.id}_related_$i',
          name: '${currentProduct.name} Variation $i',
          imageUrl: currentProduct.imageUrl,
          price: currentProduct.price + (i * 0.5), // Slightly different price
          pricePerUnit: currentProduct.pricePerUnit + (i * 0.1),
          unit: currentProduct.unit,
          productUnit: currentProduct.productUnit,
        ),
      );
    }
  }

  return mockProducts;
}
