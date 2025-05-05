import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// Screen that displays details for a specific product
class ProductDetailsScreen extends StatelessWidget {
  /// The ID of the product to display
  final String productId;

  /// Constructor
  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract category ID from product ID (format: categoryId_product_index)
    final categoryId = productId.split('_').first;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Product title
              Text(
                'Product $productId',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Category
              Text(
                'Category: $categoryId',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              
              // Price
              Text(
                '\$${(productId.hashCode % 100).toString()}.99',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
                'This is a detailed description for product $productId. '
                'It includes information about the product features, benefits, and specifications. '
                'The description helps customers make informed purchasing decisions.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Add to cart button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Show a snackbar when adding to cart
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added Product $productId to cart'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
