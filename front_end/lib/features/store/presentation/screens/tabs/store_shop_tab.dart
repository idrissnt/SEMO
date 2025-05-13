import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// Tab that displays the shop content for a specific store
class StoreShopTab extends StatelessWidget {
  /// The ID of the store
  final String storeId;
  
  const StoreShopTab({
    Key? key, 
    required this.storeId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Featured categories section
        _buildSectionTitle('Categories'),
        const SizedBox(height: 12),
        _buildCategoriesGrid(),
        
        const SizedBox(height: 24),
        
        // Featured products section
        _buildSectionTitle('Featured Products'),
        const SizedBox(height: 12),
        _buildFeaturedProducts(),
        
        const SizedBox(height: 24),
        
        // Promotions section
        _buildSectionTitle('Current Promotions'),
        const SizedBox(height: 12),
        _buildPromotions(),
      ],
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // Navigate to see all items in this section
          },
          child: const Text('View all'),
        ),
      ],
    );
  }
  
  Widget _buildCategoriesGrid() {
    // Mock categories for demonstration
    final categories = [
      {'name': 'Dogs', 'icon': Icons.pets},
      {'name': 'Cats', 'icon': Icons.pets},
      {'name': 'Birds', 'icon': Icons.flutter_dash},
      {'name': 'Fish', 'icon': Icons.water},
      {'name': 'Small Pets', 'icon': Icons.pets},
      {'name': 'Reptiles', 'icon': Icons.pest_control},
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to category
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFeaturedProducts() {
    // Mock products for demonstration
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  '\$19.99',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPromotions() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save 20% on your first order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use code: WELCOME20',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 100,
            alignment: Alignment.center,
            child: const Icon(
              Icons.card_giftcard,
              size: 50,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
