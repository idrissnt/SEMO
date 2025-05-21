import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Build the product image with hero animation
Widget buildProductImage(CategoryProduct product) {
  return Hero(
    tag: 'product_image_${product.id}',
    child: Image.network(
      product.imageUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        height: 200,
        width: double.infinity,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey,
          ),
        ),
      ),
    ),
  );
}
