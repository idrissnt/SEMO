import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

// Feature imports
// cart imports
import 'package:semo/features/cart/presentation/test/cart_items.dart';
import 'package:semo/features/cart/presentation/widgets/cart_scaffold.dart';

// store imports
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/animations/category_animation_manager.dart';
import 'package:semo/features/store/presentation/widgets/shared/app_bar.dart';
import 'package:semo/features/store/presentation/test_data/store_aisles_data.dart';
import 'package:semo/features/store/presentation/widgets/products/products_grid.dart';
import 'package:semo/features/store/presentation/widgets/category/category_filters.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

Logger _logger = Logger('ProductScreen');

/// Screen that displays a specific aisle and its categories
class ProductScreen extends StatefulWidget {
  /// The store ID
  final String storeId;

  /// The aisle ID
  final String aisleId;

  /// Creates a new aisle detail screen
  const ProductScreen({
    Key? key,
    required this.storeId,
    required this.aisleId,
  }) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with TickerProviderStateMixin {
  // ===== State Variables =====

  /// The aisle to display
  StoreAisle? _aisle;

  /// Currently selected category index
  int _selectedCategoryIndex = -1;

  /// Loading state
  bool _isLoading = true;

  // ===== Controllers =====

  /// Animation controller for the filter bar transition
  late final AnimationController _filterController;

  /// Animation controller for the products appearance
  late final AnimationController _productsController;

  /// Animation manager
  late CategoryAnimationManager _animationManager;

  /// Scroll controller for category filters
  final ScrollController _filtersScrollController = ScrollController();

  // ===== AppBar =====

  late AppBarBuilder appBarBuilder;

  // ===== Lifecycle Methods =====

  @override
  void initState() {
    super.initState();
    appBarBuilder = AppBarBuilder();
    _initializeAnimations();
    _loadAisle();
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
    _animationManager = CategoryAnimationManager(
      filterController: _filterController,
      productsController: _productsController,
      onAnimationComplete: _onAnimationComplete,
    );
  }

  // ===== Data Loading =====

  /// Loads the aisle data
  Future<void> _loadAisle() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Find the aisle in our mock data
    final aisles = StoreAisleData.getMockAisles();
    final aisle = aisles.firstWhere(
      (c) => c.id == widget.aisleId,
      orElse: () => throw Exception('Aisle not found'),
    );

    if (mounted) {
      setState(() {
        _aisle = aisle;
        _isLoading = false;

        // Auto-select the first category if available
        if (aisle.categories.isNotEmpty) {
          _selectedCategoryIndex = 0;
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
    if (_aisle == null || _aisle!.categories.isEmpty) return;

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
      appBar: appBarBuilder.buildAppBar(
          context,
          StoreRoutesConst.getStoreAislesRoute(widget.storeId),
          true,
          'Search aisles...', (query) {
        _logger.info('Search query: $query');
      }),
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

  // ===== Main Content Methods =====

  /// Builds the main content of the screen
  Widget _buildContent() {
    if (_isLoading || _aisle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Category filters with slide-in and fade animation
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
        child: _buildCategoryFilters(),
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

  /// Builds the category filters at the top of the screen
  Widget _buildCategoryFilters() {
    if (_aisle == null) {
      return const SizedBox.shrink();
    }

    return CategoryFilters(
      categories: _aisle!.categories,
      selectedIndex: _selectedCategoryIndex,
      scrollController: _filtersScrollController,
      onCategoryTap: (index) {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
    );
  }

  /// Builds a grid of products for the selected category
  Widget _buildProductsGridWithTitle() {
    if (_aisle == null ||
        _selectedCategoryIndex < 0 ||
        _selectedCategoryIndex >= _aisle!.categories.length) {
      return const SizedBox.shrink();
    }

    final category = _aisle!.categories[_selectedCategoryIndex];

    return ProductsGrid(
      category: category,
      storeId: widget.storeId,
      aisleId: widget.aisleId,
    );
  }
}
