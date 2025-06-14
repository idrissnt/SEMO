import 'package:flutter/material.dart';
import 'package:semo/features/cart/presentation/test/cart_items.dart';
import 'package:semo/features/cart/presentation/widgets/cart_scaffold.dart';
import 'package:semo/features/order/routes/const.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/test_data/store_aisles_data.dart';
import 'package:semo/features/store/presentation/widgets/category/category_products_list.dart';
import 'package:semo/features/store/presentation/widgets/store_shop_tab/app_bar.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger('StoreShopTab');

/// Tab that displays the shop content for a specific store
class StoreShopTab extends StatefulWidget {
  const StoreShopTab({
    Key? key,
  }) : super(key: key);

  @override
  State<StoreShopTab> createState() => _StoreShopTabState();
}

class _StoreShopTabState extends State<StoreShopTab>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  // state variables that will change based on scroll position
  bool _isScrolled = false;

  /// Store brand data
  final StoreBrand _store = storeBrandData;

  // Scroll progress value from 0.0 (not scrolled) to 1.0 (fully scrolled)
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // add listener to scroll controller
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Instead of a binary state, calculate a progress value between 0 and 1
    // based on scroll position between 0 and 100
    final scrollProgress = (_scrollController.offset / 100).clamp(0.0, 1.0);

    // Update the state regardless of threshold to get smooth animation
    setState(() {
      // For binary state changes (when needed)
      _isScrolled = scrollProgress > 0.5;

      // Store the scroll progress for smooth animations
      _scrollProgress = scrollProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CartScaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
      cart: mockCart,
      onCartTap: () {
        _logger.info('Cart tapped');
      },
      onUpdateQuantity: (productId, quantity) {
        _logger.info('Update quantity: $productId, $quantity');
      },
      onRemoveItem: (productId) {
        _logger.info('Remove item: $productId');
      },
      onViewCartPressed: () {
        _logger.info('View cart pressed');
      },
    );
  }

  Widget _buildAppBar() {
    return StoreShopAppBar(
      store: _store,
      scrollController: _scrollController,
      isScrolled: _isScrolled,
      scrollProgress: _scrollProgress,
      backRoute: OrderRoutesConstants.order,
    );
  }

  Widget _buildMainContent() {
    // Get all store aisles data
    final List<StoreAisle> aisles = StoreAisleData.getMockAisles();

    return
        // Category products sections - dynamically created for each category
        _buildCategoryProductSections(aisles);
  }

  /// Builds product sections for each category
  Widget _buildCategoryProductSections(List<StoreAisle> aisles) {
    // Create a list to hold all category widgets
    List<Widget> categoryWidgets = [];

    // For each aisle, create sections for its categories
    for (final aisle in aisles) {
      if (aisle.categories.first.products.isNotEmpty) {
        categoryWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryProductsList(
                aisle: aisle,
                storeBrand: _store,
              ),
              const SizedBox(height: 2), // Add spacing between categories
            ],
          ),
        );
      }
    }

    return Column(children: categoryWidgets);
  }
}
