import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/categories/store_category.dart';
import 'package:semo/features/store/presentation/test_data/store_categories_data.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// Screen that displays products for a specific subcategory
class SubcategoryProductsScreen extends StatefulWidget {
  /// The store ID
  final String storeId;

  /// The category ID
  final String categoryId;

  /// The subcategory ID
  final String subcategoryId;

  /// Creates a new subcategory products screen
  const SubcategoryProductsScreen({
    Key? key,
    required this.storeId,
    required this.categoryId,
    required this.subcategoryId,
  }) : super(key: key);

  @override
  State<SubcategoryProductsScreen> createState() =>
      _SubcategoryProductsScreenState();
}

class _SubcategoryProductsScreenState extends State<SubcategoryProductsScreen> {
  /// The subcategory to display
  StoreSubcategory? _subcategory;

  /// All subcategories in the same category
  List<StoreSubcategory> _allSubcategories = [];

  /// The parent category name
  String? _categoryName;

  /// Loading state
  bool _isLoading = true;

  /// Scroll controller for subcategory filters
  final ScrollController _filtersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSubcategory();
  }

  @override
  void dispose() {
    _filtersScrollController.dispose();
    super.dispose();
  }

  /// Loads the subcategory data
  Future<void> _loadSubcategory() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find the category and subcategory in our mock data
    final categories = StoreCategoriesData.getMockCategories();
    final category = categories.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () => throw Exception('Category not found'),
    );

    final subcategory = category.subcategories.firstWhere(
      (s) => s.id == widget.subcategoryId,
      orElse: () => throw Exception('Subcategory not found'),
    );

    if (mounted) {
      setState(() {
        _subcategory = subcategory;
        _allSubcategories = category.subcategories;
        _categoryName = category.name;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _categoryName!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(StoreRoutesConst.getStoreCategoryRoute(
            widget.storeId,
            widget.categoryId,
          )),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Subcategory filters at the top
                _buildSubcategoryFilters(),

                // Products in horizontal scrollable lists
                Expanded(
                  child: _buildProductsLayout(),
                ),
              ],
            ),
    );
  }

  /// Builds the subcategory filters at the top of the screen
  Widget _buildSubcategoryFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        controller: _filtersScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _allSubcategories.length,
        itemBuilder: (context, index) {
          final subcategory = _allSubcategories[index];
          final isSelected = subcategory.id == _subcategory!.id;

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                context.go(StoreRoutesConst.getStoreSubcategoryRoute(
                  widget.storeId,
                  widget.categoryId,
                  subcategory.id,
                ));
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                subcategory.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the products layout with horizontal scrollable lists
  Widget _buildProductsLayout() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const SizedBox(height: 16),
        _buildProductSection(_subcategory!.name, _subcategory!.products),
      ],
    );
  }

  /// Builds a product section with a header and horizontal list of products
  Widget _buildProductSection(String title, List<CategoryProduct> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable product list
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with discount badge
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

              // Discount badge
              if (hasDiscount)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SALE',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                Row(
                  children: [
                    // Current price
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasDiscount ? Colors.red : Colors.black,
                          ),
                    ),

                    const SizedBox(width: 8),

                    // Original price (if discounted)
                    if (hasDiscount)
                      Text(
                        '\$${product.originalPrice!.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[600],
                            ),
                      ),
                  ],
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
