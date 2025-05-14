import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/categories/store_category.dart';
import 'package:semo/features/store/presentation/test_data/store_categories_data.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// Screen that displays a specific category and its subcategories
class CategoryDetailScreen extends StatefulWidget {
  /// The store ID
  final String storeId;

  /// The category ID
  final String categoryId;

  /// Creates a new category detail screen
  const CategoryDetailScreen({
    Key? key,
    required this.storeId,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  /// The category to display
  StoreCategory? _category;

  /// Set of expanded subcategory indices
  final Set<int> _expandedSubcategories = {};

  /// Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  /// Loads the category data
  Future<void> _loadCategory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find the category in our mock data
    final categories = StoreCategoriesData.getMockCategories();
    final category = categories.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () => throw Exception('Category not found'),
    );

    if (mounted) {
      setState(() {
        _category = category;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _category!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go(StoreRoutesConst.getStoreAislesRoute(widget.storeId)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCategoryContent(),
    );
  }

  /// Builds the category content
  Widget _buildCategoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subcategories list
        Expanded(
          child: _buildSubcategoriesList(),
        ),
      ],
    );
  }

  /// Builds the subcategories list
  Widget _buildSubcategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _category!.subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = _category!.subcategories[index];
        return _buildSubcategoryItem(subcategory, index);
      },
    );
  }

  /// Builds a subcategory item
  Widget _buildSubcategoryItem(StoreSubcategory subcategory, int index) {
    final isExpanded = _expandedSubcategories.contains(index);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Subcategory header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSubcategories.remove(index);
                } else {
                  _expandedSubcategories.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Subcategory image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      subcategory.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Subcategory details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subcategory name
                        Text(
                          subcategory.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),

                        // Subcategory description
                        if (subcategory.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subcategory.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Product count
                        const SizedBox(height: 8),
                        Text(
                          '${subcategory.products.length} products',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
          ),

          // Products section (only shown when expanded)
          if (isExpanded) _buildProductsSection(subcategory),

          // View all button
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.go(StoreRoutesConst.getStoreSubcategoryRoute(
                      widget.storeId,
                      widget.categoryId,
                      subcategory.id,
                    ));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View All Products'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a horizontal scrollable list of products for a subcategory
  Widget _buildProductsSection(StoreSubcategory subcategory) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: subcategory.products.length,
        itemBuilder: (context, index) {
          final product = subcategory.products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  /// Builds a product card
  Widget _buildProductCard(CategoryProduct product) {
    final hasDiscount = product.originalPrice != null;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Stack(
            children: [
              // Product image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  product.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
            ],
          ),

          // Product details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Product unit
                Text(
                  product.unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),

                const SizedBox(height: 8),

                // Price
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasDiscount ? Colors.red : Colors.black,
                      ),
                ),

                const SizedBox(height: 8),

                // Add to cart button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement add to cart functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
