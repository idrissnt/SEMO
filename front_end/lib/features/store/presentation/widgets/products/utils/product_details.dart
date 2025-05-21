import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Build the product details section (name and price)
Widget buildProductDetails(CategoryProduct product) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Product name
      Text(
        product.name,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),

      // Price information
      Row(
        children: [
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(\$${product.pricePerUnit.toStringAsFixed(2)}/${product.unit})',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      Text(
        product.productUnit,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}
