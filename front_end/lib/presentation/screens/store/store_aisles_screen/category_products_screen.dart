import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/store/product_model.dart';
import '../../../widgets/storescreen/store_aisles_screen/product_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String storeId;
  final String categoryName;
  final Map<String, dynamic> category;

  const CategoryProductsScreen({
    Key? key,
    required this.storeId,
    required this.categoryName,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen>
    with TickerProviderStateMixin {
  final AppLogger _logger = AppLogger();
  late TabController _tabController;
  List<String> _subcategories = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logger.debug(
        'CategoryProductsScreen: Initializing for category ${widget.categoryName}');
    _extractSubcategories();
    _tabController =
        TabController(length: _subcategories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _extractSubcategories() {
    // Extract subcategories from products in this category
    final Set<String> subcategorySet = {};

    // Check if the category has a subcategories list
    if (widget.category.containsKey('subcategories') &&
        widget.category['subcategories'] is List) {
      for (var subcategory in widget.category['subcategories']) {
        if (subcategory is Map<String, dynamic> &&
            subcategory.containsKey('name') &&
            subcategory['name'] != null) {
          subcategorySet.add(subcategory['name'].toString());
        }
      }
    }

    // Also check for subcategory field in products (original approach)
    if (widget.category.containsKey('products') &&
        widget.category['products'] is List) {
      for (var product in widget.category['products']) {
        if (product.containsKey('subcategory') &&
            product['subcategory'] != null &&
            product['subcategory'].toString().isNotEmpty) {
          subcategorySet.add(product['subcategory'].toString());
        }
      }
    }

    _subcategories = subcategorySet.toList()..sort();
    _logger.debug('Found ${_subcategories.length} subcategories');
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<dynamic> _getFilteredProducts(String? subcategory) {
    List<dynamic> allProducts = [];

    // Get products directly from the category
    if (widget.category.containsKey('products') &&
        widget.category['products'] is List) {
      allProducts.addAll(widget.category['products']);
    }

    // Get products from subcategories
    if (widget.category.containsKey('subcategories') &&
        widget.category['subcategories'] is List) {
      for (var subcat in widget.category['subcategories']) {
        if (subcat is Map<String, dynamic>) {
          // If a subcategory is selected, only get products from that subcategory
          if (subcategory != null &&
              subcat.containsKey('name') &&
              subcat['name'] != subcategory) {
            continue;
          }

          if (subcat.containsKey('products') && subcat['products'] is List) {
            // Add products from this subcategory
            for (var product in subcat['products']) {
              if (product is Map<String, dynamic>) {
                // Add the subcategory name to the product for filtering
                if (subcat.containsKey('name')) {
                  product = Map<String, dynamic>.from(product);
                  product['subcategory'] = subcat['name'];
                }
                allProducts.add(product);
              }
            }
          }
        }
      }
    }

    // If no subcategory is selected or we're showing "All", return all products
    if (subcategory == null) {
      // Filter by search query if needed
      if (_searchQuery.isNotEmpty) {
        return allProducts.where((product) {
          final name = product['name']?.toString().toLowerCase() ?? '';
          final description =
              product['description']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          return name.contains(query) || description.contains(query);
        }).toList();
      }
      return allProducts;
    }

    // Filter products by the selected subcategory and search query
    return allProducts.where((product) {
      // Filter by subcategory
      final bool matchesSubcategory = product['subcategory'] != null &&
          product['subcategory'].toString() == subcategory;

      // Filter by search query if not empty
      final bool matchesSearch = _searchQuery.isEmpty ||
          ((product['name'] != null &&
                  product['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())) ||
              (product['description'] != null &&
                  product['description']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase())));

      return matchesSubcategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // We don't need to wrap this screen with GestureNavigationWrapper here
    // because it's already wrapped in the store_shell_route.dart when navigating
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'All'),
            ..._subcategories
                .map((subcategory) => Tab(text: subcategory))
                .toList(),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in ${widget.categoryName}',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
              onChanged: _onSearchQueryChanged,
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // "All" tab
                _buildProductsGrid(null),
                // Subcategory tabs
                ..._subcategories
                    .map((subcategory) => _buildProductsGrid(subcategory))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(String? subcategory) {
    final filteredProducts = _getFilteredProducts(subcategory);

    if (filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _searchQuery.isNotEmpty
                ? 'No products found matching "$_searchQuery"'
                : 'No products available in this ${subcategory ?? 'category'}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    // Convert the dynamic product to a ProductModel or create a simplified version
    return ProductCard(
      product: ProductModel(
        id: product['id']?.toString() ?? '',
        name: product['name']?.toString() ?? 'Unknown Product',
        price: (product['price'] ?? 0.0).toDouble(),
        imageUrl: product['image_url']?.toString() ?? '',
        description: product['description']?.toString() ?? '',
        categoryName: widget.categoryName,
        isSeasonalProduct: false,
        parentCategory: null,
        stores: const [],
        unit: '',
        subcategory: product['subcategory']?.toString() ?? '',
        quantity: product['quantity']?.toString() ?? '1',
      ),
      onTap: () {
        // Navigate to product details screen if needed
        _logger.debug('Product tapped: ${product['name']}');
      },
    );
  }
}
