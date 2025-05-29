import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/models.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

/// Screen that displays a list of products in a vertical scrollable way
class CommunityOrderStartedScreen extends StatefulWidget {
  final CommunityOrder order;

  /// Creates a new product list screen
  const CommunityOrderStartedScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<CommunityOrderStartedScreen> createState() =>
      _CommunityOrderStartedScreenState();
}

class _CommunityOrderStartedScreenState
    extends State<CommunityOrderStartedScreen> {
  int _selectedCategoryIndex = -1;
  final ScrollController _filtersScrollController = ScrollController();
  bool _showGuidanceTitle = true; // Track if guidance title should be shown

  // Lists to hold order items in different states
  late final List<OrderItem> _inProgressItems = [];
  late final List<OrderItem> _customerReviewingItems = [];
  late final List<OrderItem> _foundItems = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = 0;

    // Initialize with sample items for testing
    // In a real app, these would come from the order or an API
    final allItems = OrderItem.getSampleItems();

    // Sort items into the appropriate lists based on their status
    for (var item in allItems) {
      switch (item.status) {
        case OrderItemStatus.inProgress:
          _inProgressItems.add(item);
          break;
        case OrderItemStatus.customerReviewing:
          _customerReviewingItems.add(item);
          break;
        case OrderItemStatus.found:
          _foundItems.add(item);
          break;
      }
    }
  }

  @override
  void dispose() {
    _filtersScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            'Commande de ${widget.order.customerName}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.close, size: 20, color: Colors.black),
            ),
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.chat_bubble_text),
            onPressed: () {
              // Handle share action
            },
          ),
        ],
      ),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            ProductControlFilters(
              categories: const [
                'En cours',
                'Le client examine',
                'Trouvé',
              ],
              // Pass the counts of items in each category
              itemCounts: [
                _inProgressItems.length,
                _customerReviewingItems.length,
                _foundItems.length,
              ],
              selectedIndex: _selectedCategoryIndex,
              onCategoryTap: (index) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
            ),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the content for the selected tab
  Widget _buildTabContent() {
    List<OrderItem> items;

    switch (_selectedCategoryIndex) {
      case 0: // En cours
        items = _inProgressItems;
        break;
      case 1: // Le client examine
        items = _customerReviewingItems;
        break;
      case 2: // Trouvé
        items = _foundItems;
        break;
      default:
        items = [];
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Add guidance title for the "En cours" tab
    if (_selectedCategoryIndex == 0) {
      return Column(
        children: [
          // Guidance title - only show if _showGuidanceTitle is true
          if (_showGuidanceTitle)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.blue.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Voici les produits à acheter. Sélectionnez un article pour voir le détail et indiquer si vous l\'avez trouvé ou non',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 1, 133, 242),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16),
                              child: Text(
                                'Ok',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 1, 133, 242),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showGuidanceTitle = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // List content
          Expanded(
            child: _buildAisleGroupedList(items),
          ),
        ],
      );
    }

    // For other tabs, just show the aisle-grouped list
    return _buildAisleGroupedList(items);
  }

  // Build a list of items grouped by aisle
  Widget _buildAisleGroupedList(List<OrderItem> items) {
    // Group items by aisle
    final Map<String, List<OrderItem>> itemsByAisle = {};

    for (var item in items) {
      final aisle = item.aisle;
      if (!itemsByAisle.containsKey(aisle)) {
        itemsByAisle[aisle] = [];
      }
      itemsByAisle[aisle]!.add(item);
    }

    // Sort aisles alphabetically
    final sortedAisles = itemsByAisle.keys.toList()..sort();

    // Track the global index for continuous color cycling across aisles
    int globalItemIndex = 0;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      // Each aisle gets a header + its items
      itemCount: sortedAisles.length,
      itemBuilder: (context, aisleIndex) {
        final aisle = sortedAisles[aisleIndex];
        final aisleItems = itemsByAisle[aisle]!;

        // Create a list of widgets for this aisle's items
        final List<Widget> aisleItemWidgets = [];

        // Generate item cards with continuous color cycling
        for (int i = 0; i < aisleItems.length; i++) {
          aisleItemWidgets.add(
            OrderItemCard(
              storeName: widget.order.storeName,
              item: aisleItems[i],
              index:
                  globalItemIndex++, // Use and increment global index for continuous color cycling
              onViewDetails: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Détails de ${aisleItems[i].name}'),
                  ),
                );
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aisle header
            _buildAisleHeader(aisle),

            // Items in this aisle
            ...aisleItemWidgets,
          ],
        );
      },
    );
  }

  // Build the aisle header
  Widget _buildAisleHeader(String aisle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Icon(Icons.shopping_cart, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            aisle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedCategoryIndex == 2
                ? Icons.check_circle
                : Icons.shopping_basket,
            size: 64,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyListMessage(),
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Get the appropriate empty list message based on the selected tab
  String _getEmptyListMessage() {
    switch (_selectedCategoryIndex) {
      case 0:
        return 'Tous les articles ont été traités';
      case 1:
        return 'Aucun article en attente de réponse du client';
      case 2:
        return 'Vous n\'avez pas encore trouvé d\'articles';
      default:
        return 'Aucun article à afficher';
    }
  }
}
