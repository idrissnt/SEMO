import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
// We're using local font size constants instead of app_dimensions.dart
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final AppLogger _logger = AppLogger();

  // Font size constants
  static const double _fontSizeXSmall = 10.0;
  static const double _fontSizeSmall = 12.0;
  static const double _fontSizeMedium = 14.0;

  List<OrderItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.length > 2) {
      _performSearch(_searchController.text);
    } else if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _performSearch(String query) {
    // In a real app, this would be a repository call
    // For now, we'll just filter the sample items
    setState(() {
      _isSearching = true;
      _searchResults = OrderItem.getSampleItems()
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) &&
              item.id != widget.orderItem.id)
          .toList();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Produit non trouvé',
          style: TextStyle(
            fontSize: _fontSizeXSmall,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original item card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildOriginalItemCard(),
          ),

          // Divider with text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(thickness: 1, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Produit non disponible',
                    style: TextStyle(
                      fontSize: _fontSizeSmall,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(thickness: 1, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Replacement items or search
          Expanded(
            child: widget.replacementItems != null &&
                    widget.replacementItems!.isNotEmpty
                ? _buildReplacementsList()
                : _buildSearchSection(),
          ),

          // Bottom action bar
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
        padding: const EdgeInsets.all(12.0),
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
                      fontSize: _fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.orderItem.quantity} ${widget.orderItem.unit}',
                    style: TextStyle(
                      fontSize: _fontSizeSmall,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.orderItem.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: _fontSizeSmall,
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
                  fontSize: _fontSizeXSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplacementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Produits de remplacement suggérés',
            style: TextStyle(
              fontSize: _fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: widget.replacementItems?.length ?? 0,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = widget.replacementItems![index];
              return _buildReplacementItemCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReplacementItemCard(OrderItem item) {
    return InkWell(
      onTap: () => _selectReplacementItem(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
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
                  image: NetworkImage(item.imageUrl),
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
                    item.name,
                    style: const TextStyle(
                      fontSize: _fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity} ${item.unit}',
                    style: TextStyle(
                      fontSize: _fontSizeSmall,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: _fontSizeSmall,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Select button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Sélectionner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontSizeXSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rechercher un produit de remplacement',
                style: TextStyle(
                  fontSize: _fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _performSearch,
                ),
              ),
            ],
          ),
        ),
        // Search results or empty state
        Expanded(
          child: _isSearching
              ? _searchResults.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _buildReplacementItemCard(_searchResults[index]);
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun résultat trouvé',
                            style: TextStyle(
                              fontSize: _fontSizeMedium,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Recherchez un produit de remplacement',
                        style: TextStyle(
                          fontSize: _fontSizeMedium,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
