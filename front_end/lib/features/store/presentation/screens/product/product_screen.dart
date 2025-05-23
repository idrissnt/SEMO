import 'package:flutter/material.dart';
// import 'package:logging/logging.dart';

// Feature imports
// cart imports
import 'package:semo/features/order/presentation/widgets/app_bar/search_bar_widget.dart';

// store imports
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/animations/category_animation_manager.dart';
import 'package:semo/features/store/presentation/test_data/store_aisles_data.dart';
import 'package:semo/features/store/presentation/widgets/products/products_grid.dart';
import 'package:semo/features/store/presentation/widgets/category/category_filters.dart';

// Logger _logger = Logger('ProductScreen');

/// Screen that displays a specific aisle and its categories
class ProductScreen extends StatefulWidget {
  final String storeId;
  final String aisleId;
  final String? categoryId;

  const ProductScreen({
    Key? key,
    required this.storeId,
    required this.aisleId,
    this.categoryId,
  }) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with TickerProviderStateMixin {
  // ===== State Variables =====

  StoreAisle? _aisle;
  int _selectedCategoryIndex = -1;
  bool _isLoading = true;

  // ===== Controllers =====

  late final AnimationController _filterController;
  late final AnimationController _productsController;
  late CategoryAnimationManager _animationManager;
  final ScrollController _filtersScrollController = ScrollController();

  // ===== Lifecycle Methods =====

  @override
  void initState() {
    super.initState();
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
        // If categoryId is provided, find and select that category
        if (widget.categoryId != null) {
          // Find the index of the category with the matching ID
          final categoryIndex = aisle.categories.indexWhere(
            (category) => category.id == widget.categoryId,
          );

          // If found, select it; otherwise default to the first category
          _selectedCategoryIndex = categoryIndex != -1 ? categoryIndex : 0;
        } else if (aisle.categories.isNotEmpty) {
          // Default: select the first category if no specific category requested
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0, // Remove default title spacing
        title: Container(
          margin: const EdgeInsets.only(
              right: 16), // Add right margin to match left side
          child: const SearchBarWidget(
            isScrolled: false,
          ),
        ),
        leading: null,
        // Remove any default padding
        toolbarHeight: kToolbarHeight - 4, // Slightly reduce the toolbar height
      ),
      body: _buildContent(),
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
