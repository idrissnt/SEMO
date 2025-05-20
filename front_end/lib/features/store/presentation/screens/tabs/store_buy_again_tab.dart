import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/search_bar_widget.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/test_data/store_aisles_data.dart';
import 'package:semo/features/store/presentation/widgets/products/product_card.dart';

/// Tab that displays previously purchased items for a specific store
class StoreBuyAgainTab extends StatefulWidget {
  /// The ID of the store
  final String storeId;

  const StoreBuyAgainTab({
    Key? key,
    required this.storeId,
  }) : super(key: key);

  @override
  State<StoreBuyAgainTab> createState() => _StoreBuyAgainTabState();
}

class _StoreBuyAgainTabState extends State<StoreBuyAgainTab> {
  final StoreBrand _store = storeBrandData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const SearchBarWidget(
          isScrolled: false,
        ),
        leading: null,
      ),
      body: CustomScrollView(
        slivers: [
          // Recent orders section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Commandes récentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentOrders(),
                  const SizedBox(height: 24),
                  const Text(
                    'Articles fréquemment achetés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Frequent items grid
          _buildFrequentItems(),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    final products = _store.aisles!.first.categories.first.products;

    // Mock recent orders
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${products.length} articles • ${(products.map((p) => p.price).reduce((a, b) => a + b)).toStringAsFixed(2)}€',
                      ),
                      Text(
                        'il y a ${index + 1} semaine${index > 0 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...products
                          .take(3)
                          .map((product) => Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(product.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(),
                      if (products.length > 3)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black,
                            shape: const CircleBorder(),
                            minimumSize: const Size(40, 40),
                          ),
                          child: Text(
                            '+${products.length - 3}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Add all items to cart
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ajouter tout au panier',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrequentItems() {
    // Add null checks and return a placeholder if no data
    if (_store.aisles == null ||
        _store.aisles!.isEmpty ||
        _store.aisles!.first.categories.isEmpty ||
        _store.aisles!.first.categories.first.products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text('No frequent items found'),
          ),
        ),
      );
    }

    final products = _store.aisles!.first.categories.first.products;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.80,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }
}
