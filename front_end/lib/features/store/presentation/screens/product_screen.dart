import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

// Core imports
import 'package:semo/features/cart/presentation/test/cart_items.dart';
import 'package:semo/features/cart/presentation/widgets/cart_scaffold.dart';

// Feature imports
import 'package:semo/features/store/domain/entities/categories/store_category.dart';
import 'package:semo/features/store/presentation/animations/subcategory_animation_manager.dart';
import 'package:semo/features/store/presentation/screens/app_bar/search_bar_widget.dart';
import 'package:semo/features/store/presentation/test_data/store_categories_data.dart';
import 'package:semo/features/store/presentation/widgets/products_grid.dart';
import 'package:semo/features/store/presentation/widgets/subcategory_filters.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

Logger _logger = Logger('ProductScreen');

/// Screen that displays a specific category and its subcategories
class ProductScreen extends StatefulWidget {
  /// The store ID
  final String storeId;

  /// The category ID
  final String categoryId;

  /// Creates a new category detail screen
  const ProductScreen({
    Key? key,
    required this.storeId,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with TickerProviderStateMixin {
  // ===== State Variables =====

  /// The category to display
  StoreCategory? _category;

  /// Currently selected subcategory index
  int _selectedSubcategoryIndex = -1;

  /// Loading state
  bool _isLoading = true;

  // ===== Controllers =====

  /// Animation controller for the filter bar transition
  late final AnimationController _filterController;

  /// Animation controller for the products appearance
  late final AnimationController _productsController;

  /// Animation manager
  late SubcategoryAnimationManager _animationManager;

  /// Scroll controller for subcategory filters
  final ScrollController _filtersScrollController = ScrollController();

  // ===== Lifecycle Methods =====

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCategory();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _filterController.dispose();
    _productsController.dispose();
    _filtersScrollController.dispose();
    super.dispose();
  }

  // ===== Initialization Methods =====

  /// Initialize animation controllers and manager
  void _initializeAnimations() {
    // Create animation controllers with appropriate durations
    _filterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _productsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Initialize animation manager with all controllers
    _animationManager = SubcategoryAnimationManager(
      filterController: _filterController,
      productsController: _productsController,
      onAnimationComplete: _onAnimationComplete,
    );
  }

  // ===== Data Loading =====

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

        // Auto-select the first subcategory if available
        if (category.subcategories.isNotEmpty) {
          _selectedSubcategoryIndex = 0;
        }
      });

      // Wait for the layout to be built before starting animations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateInitialTransition();
      });
    }
  }

  // ===== Animation Methods =====

  /// Called when animation sequence is complete
  void _onAnimationComplete() {
    if (mounted) {
      setState(() {
        // Update UI if needed after animation completes
      });
    }
  }

  /// Animates the initial transition when entering the screen
  void _animateInitialTransition() {
    if (_category == null || _category!.subcategories.isEmpty) return;

    // Let the animation manager handle the entire animation sequence
    _animationManager.startAnimationSequenceFromTheTop(context);
  }

  // ===== Main Build Method =====

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: _buildAppBar(context),
  //     body: _buildContent(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return CartScaffold(
      appBar: _buildAppBar(context),
      body: _buildContent(),
      cart: mockCart, // Use the mock cart
      onCartTap: () {
        // Simple print for testing
        _logger.info('Cart tapped');
      },
      onUpdateQuantity: (productId, quantity) {
        // Simple print for testing
        _logger.info('Update quantity: $productId, $quantity');
      },
      onRemoveItem: (productId) {
        // Simple print for testing
        _logger.info('Remove item: $productId');
      },
      onViewCartPressed: () {
        // Simple print for testing
        _logger.info('View cart pressed');
      },
      onCheckoutPressed: () {
        // Simple print for testing
        _logger.info('Checkout pressed');
      },
    );
  }

  // ===== App Bar Methods =====

  /// Builds the app bar with title and actions
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: _buildSearchBar(),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () =>
            context.go(StoreRoutesConst.getStoreAislesRoute(widget.storeId)),
      ),
    );
  }

  /// Builds the search bar using the reusable SearchBarWidget component
  Widget _buildSearchBar() {
    return SearchBarWidget(
      hintText: 'Rechercher',
      onQueryChanged: _handleSearchQuery,
      minQueryLength: 3,
      backgroundColor: Colors.grey.shade200,
    );
  }
  
  /// Handles search queries from the search bar
  void _handleSearchQuery(String query) {
    _logger.info('Search query: $query');
    // Implement search functionality here
    // For example, navigate to search results or filter current products
  }

  // ===== Main Content Methods =====

  /// Builds the main content of the screen
  Widget _buildContent() {
    if (_isLoading || _category == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Subcategory filters with slide-in and fade animation
        _buildAnimatedFilters(),

        // Products grid with fade-in animation
        Expanded(child: _buildAnimatedProducts()),
      ],
    );
  }

  // ===== Animation UI Methods =====

  /// Builds the animated filters section
  Widget _buildAnimatedFilters() {
    return SlideTransition(
      position: _animationManager.filterSlideAnimation,
      child: FadeTransition(
        opacity: _animationManager.filterAnimation,
        child: _buildSubcategoryFilters(),
      ),
    );
  }

  /// Builds the animated products section
  Widget _buildAnimatedProducts() {
    return ClipRect(
      child: SlideTransition(
        position: _animationManager.productsSlideAnimation,
        child: FadeTransition(
          opacity: _animationManager.productsAnimation,
          child: _buildProductsGridWithTitle(),
        ),
      ),
    );
  }

  // ===== Component UI Methods =====

  /// Builds the subcategory filters at the top of the screen
  Widget _buildSubcategoryFilters() {
    if (_category == null) {
      return const SizedBox.shrink();
    }

    return SubcategoryFilters(
      subcategories: _category!.subcategories,
      selectedIndex: _selectedSubcategoryIndex,
      scrollController: _filtersScrollController,
      onSubcategoryTap: (index) {
        setState(() {
          _selectedSubcategoryIndex = index;
        });
      },
    );
  }

  /// Builds a grid of products for the selected subcategory
  Widget _buildProductsGridWithTitle() {
    if (_category == null ||
        _selectedSubcategoryIndex < 0 ||
        _selectedSubcategoryIndex >= _category!.subcategories.length) {
      return const SizedBox.shrink();
    }

    final subcategory = _category!.subcategories[_selectedSubcategoryIndex];

    return ProductsGrid(
      subcategory: subcategory,
      storeId: widget.storeId,
      categoryId: widget.categoryId,
    );
  }
}
