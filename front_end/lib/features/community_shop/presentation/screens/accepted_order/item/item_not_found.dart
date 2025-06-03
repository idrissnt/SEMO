import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/screens/image_viewer_screen.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/models.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/core/utils/logger.dart';

class CommunityOrderItemNotFoundScreen extends StatefulWidget {
  final OrderItem orderItem;
  final CommunityOrder order;
  final List<OrderItem>? replacementItems;

  const CommunityOrderItemNotFoundScreen({
    Key? key,
    required this.orderItem,
    required this.order,
    this.replacementItems,
  }) : super(key: key);

  @override
  State<CommunityOrderItemNotFoundScreen> createState() =>
      _CommunityOrderItemNotFoundScreenState();
}

class _CommunityOrderItemNotFoundScreenState
    extends State<CommunityOrderItemNotFoundScreen> {
  final AppLogger _logger = AppLogger();

  ScrollController scrollController = ScrollController();

  // Get sample items
  // Replace with actual items from the replacementItems
  late final List<OrderItem> replacementItems;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  List<OrderItem> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    replacementItems = widget.replacementItems ?? OrderItem.getSampleItems();
    _filteredItems = List.from(replacementItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _selectReplacementItem(OrderItem item) {
    _logger.info('Replacement item selected: ${item.id}');
    // Navigate to the item found screen with the selected replacement
    OrderProcessingInteractionService().handleOrderItemFound(
      context,
      item,
      widget.order,
    );
  }

  void _continueWithoutReplacement() {
    _logger.info('Continue without replacement');
    // Navigate back to the order started screen
    context.goNamed(
      RouteConstants.orderStartName,
      pathParameters: {'orderId': widget.order.id},
      extra: widget.order,
    );
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un produit...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterItems('', setModalState);
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) =>
                              _filterItems(value, setModalState),
                        ),
                      ),
                    ],
                  ),
                ),
                // Search results
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          // Select this item and close the modal
                          Navigator.pop(context);

                          // If you want to select this item as a replacement
                          // Uncomment the following line:
                          // _selectReplacementItem(item);

                          // Or if you just want to show it in the main screen
                          setState(() {
                            _isSearching = true;
                            _filteredItems = [item];
                          });
                        },
                        child: _buildProductImageCard(
                          context,
                          item.imageUrl,
                          item.name,
                          item.quantity,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      // Reset search when modal is closed if no item was selected
      if (!_isSearching) {
        setState(() {
          _searchController.clear();
          _filteredItems = List.from(replacementItems);
        });
      }
    });
  }

  void _filterItems(String query, StateSetter setModalState) {
    if (query.isEmpty) {
      setModalState(() {
        _filteredItems = List.from(replacementItems);
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setModalState(() {
      _filteredItems = replacementItems.where((item) {
        return item.name.toLowerCase().contains(lowercaseQuery) ||
            item.aisle.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Remplacement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.search, color: Colors.black),
              onPressed: () {
                // Handle search action
                _logger
                    .info('Search button tapped for order: ${widget.order.id}');
                _showSearchModal(context);
              },
            ),
            const SizedBox(width: 8),
          ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original item card (pinned)
          _buildOriginalItemCard(),
          // Scrollable content
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16,
                    ),
                    child: Text(
                      'Produits de remplacement suggérés',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _isSearching
                          ? _filteredItems.length
                          : replacementItems.length,
                      itemBuilder: (context, index) {
                        final item = _isSearching
                            ? _filteredItems[index]
                            : replacementItems[index];
                        return _buildProductImageCard(
                          context,
                          item.imageUrl,
                          item.name,
                          item.quantity,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              bottom: 24.0,
              top: 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _continueWithoutReplacement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continuer sans remplacement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalItemCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2.0,
          horizontal: 16.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(widget.orderItem.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.orderItem.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.orderItem.quantity} ${widget.orderItem.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.orderItem.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Non trouvé',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageCard(
      BuildContext context, String imageUrl, String name, int quantity) {
    final String heroTag = 'product-image-$imageUrl-$quantity';

    return GestureDetector(
      onTap: () {
        // Navigate to full-screen image viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(
              imageUrl: imageUrl,
              heroTag: heroTag,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  // Product image with Hero animation
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  // add badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Find the item from replacementItems that matches this imageUrl
                        final matchingItem = replacementItems.firstWhere(
                          (item) => item.imageUrl == imageUrl,
                          orElse: () => replacementItems.first,
                        );
                        _selectReplacementItem(matchingItem);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.add, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Product title
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
                // Since we don't have price and unit as parameters, we'll show just the quantity
                Text(
                  '$quantity unité(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
