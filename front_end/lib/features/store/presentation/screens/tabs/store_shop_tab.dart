import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/order/routes/const.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/test_data/store_aisles_data.dart';
import 'package:semo/features/store/presentation/widgets/store_shop_tab/app_bar.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// Tab that displays the shop content for a specific store
class StoreShopTab extends StatefulWidget {
  /// The ID of the store
  final String storeId;

  const StoreShopTab({
    Key? key,
    required this.storeId,
  }) : super(key: key);

  @override
  State<StoreShopTab> createState() => _StoreShopTabState();
}

class _StoreShopTabState extends State<StoreShopTab>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  // state variables that will change based on scroll position
  bool _isScrolled = false;

  /// Sample store brand data
  final StoreBrand _store = storeBrandData;

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

  // Scroll progress value from 0.0 (not scrolled) to 1.0 (fully scrolled)
  double _scrollProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Hero(
      tag: StoreRoutesConst.getStoreHeroTag(widget.storeId),
      child: Material(
        color: Colors.transparent,
        child: StoreShopAppBar(
          store: _store,
          scrollController: _scrollController,
          isScrolled: _isScrolled,
          scrollProgress: _scrollProgress,
          backRoute: OrderRoutesConstants.order,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Featured categories section
        _buildSectionTitle('Categories'),
        const SizedBox(height: 12),
        _buildCategoriesGrid(),

        const SizedBox(height: 24),

        // Featured products section
        _buildSectionTitle('Featured Products'),
        const SizedBox(height: 12),
        _buildFeaturedProducts(),

        const SizedBox(height: 24),

        // Promotions section
        _buildSectionTitle('Current Promotions'),
        const SizedBox(height: 12),
        _buildPromotions(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            // Navigate to see all items in this section
          },
          child: const Text('View all'),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    // Mock categories for demonstration
    final categories = [
      {'name': 'Dogs', 'icon': Icons.pets},
      {'name': 'Cats', 'icon': Icons.pets},
      {'name': 'Birds', 'icon': Icons.flutter_dash},
      {'name': 'Fish', 'icon': Icons.water},
      {'name': 'Small Pets', 'icon': Icons.pets},
      {'name': 'Reptiles', 'icon': Icons.pest_control},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to category
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProducts() {
    // Mock products for demonstration
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  '\$19.99',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotions() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save 20% on your first order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use code: WELCOME20',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 100,
            alignment: Alignment.center,
            child: const Icon(
              Icons.card_giftcard,
              size: 50,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
