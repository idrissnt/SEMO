import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/home/routes/home_routes_constants.dart';

/// Screen that displays details for a specific category
class CategoryDetailsScreen extends StatelessWidget {
  /// The ID of the category to display
  final String categoryId;

  /// Constructor
  const CategoryDetailsScreen({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category $categoryId'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Products in Category $categoryId',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final productId = '${categoryId}_product_$index';
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text('P$index'),
                      ),
                    ),
                    title: Text('Product $index'),
                    subtitle: Text('Category: $categoryId'),
                    onTap: () {
                      // Navigate to product details using the helper method
                      context.go(HomeRoutesConstants.getProductDetailsRoute(productId));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
