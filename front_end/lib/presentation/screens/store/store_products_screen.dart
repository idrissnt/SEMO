import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/logger.dart';
import '../../../data/models/store_model.dart';
import '../../blocs/store/store_bloc.dart';
import '../../blocs/store/store_event.dart';
import '../../blocs/store/store_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/storescreen/store_products_screen.dart/store_header.dart';
import '../../widgets/storescreen/store_products_screen.dart/category_tabs.dart';
import '../../widgets/storescreen/store_products_screen.dart/product_grid.dart';
import '../../widgets/storescreen/store_search_bar.dart';

class StoreProductsScreen extends StatefulWidget {
  final String storeId;
  final String? initialCategory;

  const StoreProductsScreen({
    Key? key,
    required this.storeId,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<StoreProductsScreen> createState() => _StoreProductsScreenState();
}

class _StoreProductsScreenState extends State<StoreProductsScreen>
    with AutomaticKeepAliveClientMixin {
  final AppLogger _logger = AppLogger();
  String? _selectedCategory;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Animation values
  final double _expandedAppBarHeight =
      200.0; // Increased height for better logo display
  final double _transitionStart = 40.0; // Start transition earlier
  final double _transitionEnd = 100.0; // End transition earlier

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _logger
        .debug('StoreProductsScreen: Initializing for store ${widget.storeId}');
    _logger.debug('Initial category: $_selectedCategory');
    _loadStoreData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadStoreData() {
    try {
      _logger.debug('Loading store data for ID: ${widget.storeId}');
      // Use the existing StoreBloc to load the store data
      context.read<StoreBloc>().add(LoadStoreByIdEvent(widget.storeId));
    } catch (e) {
      _logger.error('Error loading store data', error: e);
    }
  }

  void _onCategorySelected(String category) {
    _logger.debug('Category selected: $category');
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onSearchQueryChanged(String query) {
    _logger.debug('Search query changed: $query');
    setState(() {
      _searchQuery = query;
    });
  }

  // Calculate animation progress based on scroll position
  double _getAnimationProgress(double scrollPosition) {
    if (scrollPosition <= _transitionStart) {
      return 0.0;
    } else if (scrollPosition >= _transitionEnd) {
      return 1.0;
    } else {
      return (scrollPosition - _transitionStart) /
          (_transitionEnd - _transitionStart);
    }
  }

  List<Map<String, dynamic>> _getProductsForCategory(
      StoreModel store, String? category) {
    if (category == null) {
      // Return all products if no category is selected
      return store.products;
    }

    // Find the selected category
    final selectedCategory = store.categories.firstWhere(
      (cat) => cat['name'] == category,
      orElse: () => <String, dynamic>{},
    );

    if (selectedCategory.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> categoryProducts = [];

    // Check if the category has subcategories
    if (selectedCategory.containsKey('subcategories')) {
      final subcategories = selectedCategory['subcategories'];

      if (subcategories != null && subcategories is List) {
        // Collect products from all subcategories
        for (var subcategory in subcategories) {
          if (subcategory is Map<String, dynamic> &&
              subcategory.containsKey('products')) {
            final subcategoryProducts = subcategory['products'];

            if (subcategoryProducts != null && subcategoryProducts is List) {
              for (var product in subcategoryProducts) {
                if (product is Map<String, dynamic>) {
                  // Process product data if needed
                  if (product.containsKey('store_details')) {
                    final storeDetails = product['store_details'];
                    if (storeDetails != null &&
                        storeDetails is Map<String, dynamic>) {
                      if (storeDetails.containsKey('price')) {
                        product['price'] = storeDetails['price'];
                      }
                    }
                  }

                  categoryProducts.add(Map<String, dynamic>.from(product));
                }
              }
            }
          }
        }
      }
    } else if (selectedCategory.containsKey('products')) {
      // If category has products directly
      final products = selectedCategory['products'];
      if (products != null && products is List) {
        for (var product in products) {
          if (product is Map<String, dynamic>) {
            categoryProducts.add(Map<String, dynamic>.from(product));
          }
        }
      }
    }

    // Filter products by search query if needed
    if (_searchQuery.isNotEmpty) {
      categoryProducts = categoryProducts.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final description =
            product['description']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    return categoryProducts;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider.value(
      value: BlocProvider.of<StoreBloc>(context),
      child: Scaffold(
        body: BlocConsumer<StoreBloc, StoreState>(
          listenWhen: (previous, current) =>
              previous is StoreLoading && current is StoreLoaded,
          listener: (context, state) {
            if (state is StoreLoaded) {
              _logger.debug('Store data loaded successfully');
            }
          },
          buildWhen: (previous, current) =>
              current is StoreLoaded ||
              current is StoreLoading ||
              current is StoreError,
          builder: (context, state) {
            if (state is StoreLoading) {
              return const LoadingView();
            } else if (state is StoreError) {
              return ErrorView(
                message: state.message,
                onRetry: _loadStoreData,
              );
            } else if (state is StoreLoaded) {
              final store = state.store;

              final storeModel =
                  store is StoreModel ? store : StoreModel.fromEntity(store);

              // Get all category names
              final List<String> categoryNames = storeModel.categories
                  .map((category) => category['name']?.toString() ?? '')
                  .where((name) => name.isNotEmpty)
                  .toList();

              // If no category is selected, select the first one
              if (_selectedCategory == null && categoryNames.isNotEmpty) {
                _selectedCategory = categoryNames.first;
              }

              // Get products for the selected category
              final products =
                  _getProductsForCategory(storeModel, _selectedCategory);

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Force a rebuild when scrolling to update the search bar animation
                  if (notification is ScrollUpdateNotification) {
                    setState(() {});
                  }
                  return false;
                },
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // Animated App Bar
                      SliverAppBar(
                        expandedHeight: _expandedAppBarHeight,
                        pinned: true,
                        backgroundColor: Colors.blue.shade800,
                        leading: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.go('/homeScreen'),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white),
                            onPressed: () {
                              // Show store options menu
                            },
                          ),
                        ],
                        // Always show search bar in title when scrolled
                        titleSpacing: 0,
                        title: StoreSearchBar(
                          storeName: storeModel.name,
                          controller: _searchController,
                          onChanged: _onSearchQueryChanged,
                        ),
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final scrollPosition = _expandedAppBarHeight -
                                constraints.biggest.height;
                            final progress =
                                _getAnimationProgress(scrollPosition);

                            return Stack(
                              children: [
                                // Logo centered in the header - only visible when not scrolled
                                Positioned.fill(
                                  child: Opacity(
                                    opacity:
                                        1.0 - progress, // Fade out as we scroll
                                    child: StoreHeader(store: storeModel),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Category tabs
                      SliverPersistentHeader(
                        delegate: SliverCategoryTabsDelegate(
                          categories: categoryNames,
                          selectedCategory: _selectedCategory,
                          onCategorySelected: _onCategorySelected,
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: ProductGrid(
                    products: products,
                    onAddToCart: (product) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${product['name'] ?? 'Product'} added to cart'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// Delegate for the category tabs
class SliverCategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  SliverCategoryTabsDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: CategoryTabs(
        categories: categories,
        selectedCategory: selectedCategory,
        onCategorySelected: onCategorySelected,
      ),
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
