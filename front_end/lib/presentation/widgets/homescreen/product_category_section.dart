import 'package:flutter/material.dart';
import '../../../data/models/store_model.dart';
import '../../../core/utils/logger.dart';

class ProductCategorySection extends StatelessWidget {
  final String categoryTitle;
  final StoreModel store;
  final List<Map<String, dynamic>> products;
  final Function(Map<String, dynamic>)? onAddToCart;

  final AppLogger _logger = AppLogger();

  ProductCategorySection({
    Key? key,
    required this.categoryTitle,
    required this.store,
    required this.products,
    this.onAddToCart,
  }) : super(key: key) {
    _logger.debug('ProductCategorySection constructor called with:');
    _logger.debug('- Store: ${store.name}');
    _logger.debug('- Category: $categoryTitle');
    // ignore: unnecessary_brace_in_string_interps
    _logger.debug('- Products count: ${products}');
  }

  /// Creates a ProductCategorySection for a specific store by name
  static Widget forStore({
    required List<StoreModel> stores,
    required String storeName,
    required BuildContext context,
    int subcategoryIndex = 0, // Added parameter to select which subcategory to display
  }) {
    final logger = AppLogger();
    
    logger.debug('ProductCategorySection.forStore called for store: $storeName, subcategoryIndex: $subcategoryIndex');
    logger.debug('Available stores: ${stores.map((s) => s.name).join(", ")}');

    // Find the store by name
    final store = stores.firstWhere(
      (store) => store.name.toLowerCase().contains(storeName.toLowerCase()),
      orElse: () {
        logger.debug('Store $storeName not found, using first available store');
        return stores.first;
      },
    );
    
    logger.debug('Selected store: ${store.name} (ID: ${store.id})');
    
    // Safely access categories
    final categories = store.categories;
    logger.debug('Store categories count: ${categories.length}');
    if (categories.isNotEmpty) {
      logger.debug('Store categories: ${categories.map((c) => c['name']).join(", ")}');
    }

    // Get the first category from the store if available
    final categoryName = categories.isNotEmpty
        ? categories.first['name']?.toString() ?? 'Meat and seafood'
        : 'Meat and seafood';
        
    logger.debug('Selected category: $categoryName');

    // Find the selected category
    final selectedCategory = categories.firstWhere(
      (category) => category['name'] == categoryName,
      orElse: () => <String, dynamic>{},
    );

    // Check if the category has subcategories with products
    if (selectedCategory.isNotEmpty &&
        selectedCategory.containsKey('subcategories')) {
      final subcategories = selectedCategory['subcategories'];
      
      logger.debug('Found ${subcategories?.length ?? 0} subcategories in category $categoryName');

      if (subcategories != null &&
          subcategories is List &&
          subcategories.isNotEmpty) {
        
        // Get all subcategories with products
        List<Map<String, dynamic>> subcategoriesWithProducts = [];
        
        for (var subcategory in subcategories) {
          if (subcategory is Map<String, dynamic> &&
              subcategory.containsKey('products')) {
            final subcategoryProducts = subcategory['products'];

            if (subcategoryProducts != null &&
                subcategoryProducts is List &&
                subcategoryProducts.isNotEmpty) {
              logger.debug('Found ${subcategoryProducts.length} products in subcategory ${subcategory['name']}');
              subcategoriesWithProducts.add(subcategory);
            }
          }
        }
        
        logger.debug('Found ${subcategoriesWithProducts.length} subcategories with products');
        
        // Check if the requested subcategory index exists
        if (subcategoriesWithProducts.isNotEmpty && 
            subcategoryIndex < subcategoriesWithProducts.length) {
          
          // Get the subcategory at the specified index
          final selectedSubcategory = subcategoriesWithProducts[subcategoryIndex];
          logger.debug('Selected subcategory at index $subcategoryIndex: ${selectedSubcategory['name']}');
          
          final subcategoryProducts = selectedSubcategory['products'];
          List<Map<String, dynamic>> categoryProducts = [];
          
          // Process products from the selected subcategory
          if (subcategoryProducts != null && subcategoryProducts is List) {
            logger.debug('Processing ${subcategoryProducts.length} products from subcategory ${selectedSubcategory['name']}');
            
            for (var product in subcategoryProducts) {
              if (product is Map<String, dynamic>) {
                // Add store details to the product if available
                if (product.containsKey('store_details')) {
                  final storeDetails = product['store_details'];
                  if (storeDetails != null &&
                      storeDetails is Map<String, dynamic>) {
                    // Copy price from store_details to the main product
                    if (storeDetails.containsKey('price')) {
                      product['price'] = storeDetails['price'];
                      logger.debug('Extracted price ${storeDetails['price']} for product ${product['name']}');
                    }
                  }
                }

                categoryProducts.add(Map<String, dynamic>.from(product));
              }
            }
            
            logger.debug('Processed ${categoryProducts.length} products for display');
          }

          // If we found products, return the widget
          if (categoryProducts.isNotEmpty) {
            // Get the subcategory name to use as title
            final subcategoryName =
                selectedSubcategory['name']?.toString() ?? categoryName;
            
            logger.debug('Creating ProductCategorySection with title: $subcategoryName and ${categoryProducts.length} products');

            return ProductCategorySection(
              categoryTitle: subcategoryName,
              store: store,
              products: categoryProducts,
              onAddToCart: (product) {
                logger.debug('Adding product to cart: ${product['name']}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${product['name'] ?? 'Product'} added to cart'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          } else {
            logger.debug('No products found in subcategory ${selectedSubcategory['name']}');
          }
        } else {
          logger.debug('Requested subcategory index $subcategoryIndex is out of range (max: ${subcategoriesWithProducts.length - 1})');
        }
      } else {
        logger.debug('No valid subcategories found in category $categoryName');
      }
    } else {
      logger.debug('Category $categoryName has no subcategories');
    }

    logger.debug('Returning empty widget as no valid subcategory or products were found');
    // If no subcategory with products was found, return an empty widget
    return const SizedBox.shrink();
  }
  
  /// Creates multiple ProductCategorySection widgets for a specific store
  static List<Widget> forStoreMultiple({
    required List<StoreModel> stores,
    required String storeName,
    required BuildContext context,
    int maxSections = 3, // Maximum number of sections to display
  }) {
    final logger = AppLogger();
    logger.debug('forStoreMultiple called for store: $storeName, maxSections: $maxSections');
    
    final List<Widget> sections = [];
    
    // Try to create sections for different subcategories
    for (int i = 0; i < maxSections; i++) {
      logger.debug('Attempting to create section for subcategory index: $i');
      final section = forStore(
        stores: stores,
        storeName: storeName,
        context: context,
        subcategoryIndex: i,
      );
      
      // Only add non-empty sections
      if (section is! SizedBox) {
        logger.debug('Adding section for subcategory index: $i');
        sections.add(section);
      } else {
        logger.debug('No valid section found for subcategory index: $i');
      }
    }
    
    logger.debug('Created ${sections.length} sections for store: $storeName');
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    _logger.debug(
        'Building ProductCategorySection for ${store.name} - $categoryTitle');
    _logger.debug('Screen width: ${MediaQuery.of(context).size.width}px');
    _logger.debug('Screen height: ${MediaQuery.of(context).size.height}px');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildProductList(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    _logger.debug('Building header for ${store.name} - $categoryTitle');
    _logger.debug('Store logo URL: ${store.logoUrl}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Store logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                  ? Image.network(
                      store.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        _logger.warning('Failed to load store logo: $error');
                        return const Icon(Icons.store, color: Colors.grey);
                      },
                    )
                  : const Icon(Icons.store, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Category title and store name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'From ${store.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Arrow icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    _logger.debug('Building product list with ${products.length} products');

    if (products.isEmpty) {
      _logger
          .warning('No products available for this category: $categoryTitle');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No products available for this category'),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          _logger.debug(
              'Building product card for index $index: ${product['name']}');
          return _buildProductCard(context, product);
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    // Extract product details from the map
    final String name = product['name']?.toString() ?? 'Unknown Product';
    final String imageUrl = product['image_url']?.toString() ?? '';
    final double price = _extractPrice(product);
    final String unit = product['unit']?.toString() ?? '';

    _logger.debug('Building product card for: $name');
    _logger.debug('- Price: €${price.toStringAsFixed(2)}');
    _logger.debug('- Unit: $unit');
    _logger.debug('- Image URL: $imageUrl');

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with add button
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              _logger.warning(
                                  'Failed to load product image: $error');
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported,
                                    size: 40),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child:
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                  ),
                ),
                // Add to cart button
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: () {
                      _logger.debug('Add to cart button tapped for: $name');
                      if (onAddToCart != null) {
                        onAddToCart!(product);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    '€${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Product name
                  Text(
                    name,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Unit/Weight
                  if (unit.isNotEmpty)
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to extract price from product map
  double _extractPrice(Map<String, dynamic> product) {
    _logger.debug('Extracting price from product: ${product['name']}');
    _logger.debug('Product keys: ${product.keys.join(', ')}');

    // Try to get price from different possible fields
    if (product.containsKey('price')) {
      final price = product['price'];
      _logger.debug(
          'Found price field, type: ${price.runtimeType}, value: $price');
      if (price is num) return price.toDouble();
      if (price is String) return double.tryParse(price) ?? 0.0;
    }

    // Try price_range if available
    if (product.containsKey('price_range')) {
      final priceRange = product['price_range'];
      _logger.debug(
          'Found price_range field, type: ${priceRange.runtimeType}, value: $priceRange');
      if (priceRange is List && priceRange.isNotEmpty) {
        final firstPrice = priceRange.first;
        _logger.debug('Using first price from range: $firstPrice');
        if (firstPrice is num) return firstPrice.toDouble();
        if (firstPrice is String) return double.tryParse(firstPrice) ?? 0.0;
      }
    }

    _logger.warning('No valid price found for product: ${product['name']}');
    return 0.0; // Default price if not found
  }
}
