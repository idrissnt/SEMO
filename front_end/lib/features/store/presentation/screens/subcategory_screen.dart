import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/utils/action_icon_button.dart';
import 'package:semo/features/store/domain/entities/categories/store_category.dart';
import 'package:semo/features/store/presentation/animations/subcategory_animation_manager.dart';
import 'package:semo/features/store/presentation/test_data/store_categories_data.dart';
import 'package:semo/features/store/presentation/widgets/products_grid.dart';
import 'package:semo/features/store/presentation/widgets/subcategory_filters.dart';
import 'package:semo/features/store/presentation/widgets/subcategory_item.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// Screen that displays a specific category and its subcategories
class SubcategoryScreen extends StatefulWidget {
  /// The store ID
  final String storeId;

  /// The category ID
  final String categoryId;

  /// Creates a new category detail screen
  const SubcategoryScreen({
    Key? key,
    required this.storeId,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen>
    with TickerProviderStateMixin {
  /// The category to display
  StoreCategory? _category;

  /// Currently selected subcategory index
  int _selectedSubcategoryIndex = -1;

  /// Whether subcategories are pinned at the top
  bool _subcategoriesPinned = false;

  /// Animation controller for the filter bar transition
  late AnimationController _filterController;

  /// Animation controller for the elevation effect
  late AnimationController _elevationController;

  /// Animation manager
  late SubcategoryAnimationManager _animationManager;

  /// Global key for the selected subcategory
  final GlobalKey _selectedSubcategoryKey = GlobalKey();

  /// Loading state
  bool _isLoading = true;

  /// Scroll controller for subcategory filters
  final ScrollController _filtersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize filter animation controller
    _filterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Initialize elevation animation controller
    _elevationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Initialize animation manager
    _animationManager = SubcategoryAnimationManager(
      filterController: _filterController,
      elevationController: _elevationController,
    );

    _loadCategory();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _elevationController.dispose();
    _filtersScrollController.dispose();
    super.dispose();
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
        centerTitle: false,
        title: Text(
          _isLoading ? 'Loading...' : _category!.name,
          style: const TextStyle(
            color: AppColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildActionIcon(
              icon: Icons.search,
              onPressed: () {
                // Handle search
              },
              color: Colors.grey.shade300,
              iconColor: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildActionIcon(
              icon: Icons.shopping_cart,
              onPressed: () {
                // Navigate to cart
              },
              color: Colors.green,
              iconColor: Colors.white,
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              context.go(StoreRoutesConst.getStoreAislesRoute(widget.storeId)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Main content with filter bar animation
                AnimatedBuilder(
                  animation: _animationManager.filterAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        // Subcategory filters at the top (only visible when pinned)
                        if (_subcategoriesPinned ||
                            _animationManager.filterAnimation.value > 0)
                          Opacity(
                            opacity: _animationManager.filterAnimation.value,
                            child: SizeTransition(
                              sizeFactor: _animationManager.filterAnimation,
                              axis: Axis.vertical,
                              child: _buildSubcategoryFilters(),
                            ),
                          ),

                        // Main content
                        Expanded(
                          child: _subcategoriesPinned
                              ? _buildProductsGridWithTitle()
                              : _buildSubcategoriesList(),
                        ),
                      ],
                    );
                  },
                ),

                // Animated subcategory item that elevates to the top
                _animationManager.buildElevatedItem(),
              ],
            ),
    );
  }

  /// Builds action icon with badge
  Widget _buildActionIcon(
      {required IconData icon,
      required VoidCallback onPressed,
      required Color color,
      required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(0),
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ActionIconButton(
        icon: icon,
        color: iconColor,
        onPressed: onPressed,
        size: AppIconSize.xl,
      ),
    );
  }

  /// Builds the subcategory filters at the top of the screen
  Widget _buildSubcategoryFilters() {
    return SubcategoryFilters(
      subcategories: _category!.subcategories,
      selectedIndex: _selectedSubcategoryIndex,
      scrollController: _filtersScrollController,
      onSubcategoryTap: (index) {
        setState(() {
          _selectedSubcategoryIndex = index;
        });
      },
      onBackTap: () {
        // Reset the pinned state and animate back
        _filterController.reverse().then((_) {
          setState(() {
            _subcategoriesPinned = false;
            _selectedSubcategoryIndex = -1;
          });
          _animationManager.reset();
        });
      },
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
    return SubcategoryItem(
      subcategory: subcategory,
      index: index,
      isSelected: index == _selectedSubcategoryIndex,
      itemKey:
          index == _selectedSubcategoryIndex ? _selectedSubcategoryKey : null,
      onTap: (index) {
        // Set the selected subcategory index
        setState(() {
          _selectedSubcategoryIndex = index;
        });

        // Get the position of the tapped item for the animation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Calculate the position of the tapped item
          _animationManager.calculateItemPosition(_selectedSubcategoryKey);

          // Calculate the target position (top of the screen below app bar)
          final appBarHeight = AppBar().preferredSize.height;
          final statusBarHeight = MediaQuery.of(context).padding.top;
          final targetY = statusBarHeight + appBarHeight + 8; // 8px padding

          // Initialize the position animation
          _animationManager.initPositionAnimation(targetY);

          // Start the animations
          _elevationController.forward().then((_) {
            setState(() {
              _subcategoriesPinned = true;
            });
            _filterController.forward();
          });
        });
      },
    );
  }

  /// Builds a grid of products for the selected subcategory
  Widget _buildProductsGridWithTitle() {
    if (_selectedSubcategoryIndex < 0 ||
        _selectedSubcategoryIndex >= _category!.subcategories.length) {
      return const Center(child: Text('No subcategory selected'));
    }

    final subcategory = _category!.subcategories[_selectedSubcategoryIndex];

    return ProductsGrid(
      subcategory: subcategory,
      storeId: widget.storeId,
      categoryId: widget.categoryId,
    );
  }
}
