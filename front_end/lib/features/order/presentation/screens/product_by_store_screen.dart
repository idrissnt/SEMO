import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// cart imports
import 'package:semo/features/order/presentation/widgets/app_bar/search_bar_widget.dart';
import 'package:semo/features/order/presentation/widgets/sections/store_section.dart';

// store imports
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/test_data/store_aisles_data.dart';
import 'package:semo/features/store/presentation/widgets/products/products_grid.dart';
import 'package:semo/features/store/presentation/widgets/category/category_filters.dart';
import 'package:semo/features/store/routes/route_config/store_routes_const.dart';

/// Screen that displays a specific aisle and its categories
class ProductByStoreScreen extends StatefulWidget {
  final String storeId;
  final String aisleId;
  final String? categoryId;
  final StoreBrand store;

  const ProductByStoreScreen({
    Key? key,
    required this.storeId,
    required this.aisleId,
    this.categoryId,
    required this.store,
  }) : super(key: key);

  @override
  State<ProductByStoreScreen> createState() => _ProductByStoreScreenState();
}

class _ProductByStoreScreenState extends State<ProductByStoreScreen>
    with TickerProviderStateMixin {
  // ===== State Variables =====

  StoreAisle? _aisle;
  int _selectedCategoryIndex = -1;
  bool _isLoading = true;
  final ScrollController _filtersScrollController = ScrollController();

  // ===== Lifecycle Methods =====

  @override
  void initState() {
    super.initState();
    _loadAisle();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _filtersScrollController.dispose();
    super.dispose();
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
    }
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
          child: SearchBarWidget(
            isScrolled: false,
            hintText: 'search in ${widget.store.aisles?.first.name}',
          ),
        ),
        actions: [
          StoreImageButton(
            size: 40,
            store: widget.store,
            onTap: () {
              context.goNamed(
                StoreRoutesConst.storeName,
                pathParameters: {'storeId': widget.store.id},
                extra: widget.store,
              );
            },
            heroTag: StoreRoutesConst.getStoreHeroTag(widget.store.id),
          ),
          const SizedBox(width: 16),
        ],
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
        _buildCategoryFilters(),
        Expanded(child: _buildProductsGridWithTitle()),
      ],
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
