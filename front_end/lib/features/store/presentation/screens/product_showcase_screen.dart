import 'package:flutter/material.dart';
import 'package:semo/features/store/presentation/widgets/product_showcase_grid.dart';

/// A screen that demonstrates the ProductShowcaseGrid widget with a layout similar to the reference image.
class ProductShowcaseScreen extends StatelessWidget {
  const ProductShowcaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample product images from assets
    // In a real app, these would likely come from your API
    final List<String> sampleProductImages = [
      'assets/images/products/boots.jpg',      // Large image (top-left)
      'assets/images/products/necklace.jpg',   // Top-right
      'assets/images/products/jacket.jpg',     // Middle-right
      'assets/images/products/teapot.jpg',     // Bottom-left
      'assets/images/products/shirt.jpg',      // Bottom-middle
      'assets/images/products/shoes.jpg',      // Bottom-right
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Product showcase grid with French text as in the reference image
              ProductShowcaseGrid(
                imageUrls: sampleProductImages,
                isNetworkImage: false, // Using asset images
                titleText: 'La magie',
                subtitleText: 'de la nouveauté',
                additionalText: 'ne s\'arrête jamais.',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                padding: const EdgeInsets.all(16.0),
              ),
              
              // Additional content can be added below
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to product listing or other action
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color.fromARGB(255, 14, 77, 129),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Découvrir les nouveautés',
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
