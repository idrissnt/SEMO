import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/dialogs/customer_reviewing_dialog.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/models.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/product_controler_tab.dart';
import 'package:semo/features/community_shop/presentation/screens/widgets/icon_button.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';
import 'package:semo/core/utils/logger.dart';

// Global logger instance
final AppLogger _logger = AppLogger();

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

/// Represents the different tabs in the order screen
enum OrderTab {
  inProgress,
  customerReviewing,
  found,
}

/// Extension to get display names for order tabs
extension OrderTabExtension on OrderTab {
  /// Get the display name for the tab
  /// If [itemCount] is provided, it will pluralize the 'Trouvé' tab when needed
  String displayName({int? itemCount}) {
    switch (this) {
      case OrderTab.inProgress:
        return 'En cours';
      case OrderTab.customerReviewing:
        return 'À valider';
      case OrderTab.found:
        // Pluralize 'Trouvé' when there are multiple items
        return itemCount != null && itemCount > 1 ? 'Trouvés' : 'Trouvé';
    }
  }
}

/// Represents the state of the order items in the community shop
class OrderItemsState {
  final List<OrderItem> inProgressItems;
  final List<OrderItem> customerReviewingItems;
  final List<OrderItem> foundItems;

  const OrderItemsState({
    required this.inProgressItems,
    required this.customerReviewingItems,
    required this.foundItems,
  });

  /// Factory method to create state from sample data
  /// In a real app, this would be replaced by data from an API or BLoC
  factory OrderItemsState.fromSampleData() {
    final List<OrderItem> inProgressItems = [];
    final List<OrderItem> customerReviewingItems = [];
    final List<OrderItem> foundItems = [];

    // Get sample items
    final allItems = OrderItem.getSampleItems();

    // Sort items into the appropriate lists based on their status
    for (var item in allItems) {
      switch (item.status) {
        case OrderItemStatus.inProgress:
          inProgressItems.add(item);
          break;
        case OrderItemStatus.customerReviewing:
          customerReviewingItems.add(item);
          break;
        case OrderItemStatus.found:
          foundItems.add(item);
          break;
      }
    }

    return OrderItemsState(
      inProgressItems: inProgressItems,
      customerReviewingItems: customerReviewingItems,
      foundItems: foundItems,
    );
  }

  /// Get items based on the selected tab
  List<OrderItem> getItemsByTab(OrderTab tab) {
    switch (tab) {
      case OrderTab.inProgress:
        return inProgressItems;
      case OrderTab.customerReviewing:
        return customerReviewingItems;
      case OrderTab.found:
        return foundItems;
    }
  }
}

class _CommunityOrderStartedScreenState
    extends State<CommunityOrderStartedScreen> {
  // UI state
  OrderTab _selectedTab = OrderTab.inProgress;
  final ScrollController _filtersScrollController = ScrollController();
  bool _showGuidanceOverlay = true; // Track if guidance overlay should be shown

  // Data state
  late final OrderItemsState _orderItemsState;

  @override
  void initState() {
    super.initState();

    // Initialize state from sample data
    // In a real app with BLoC, this would be replaced by a BLoC provider
    _orderItemsState = OrderItemsState.fromSampleData();

    // Log initialization
    _logger.info(
        'CommunityOrderStartedScreen initialized with ${widget.order.id}');
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
      appBar: _buildAppBar(),
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar with customer name and action buttons
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        icon: buildIconButton(Icons.close, Colors.black, Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: buildIconButton(
              CupertinoIcons.chat_bubble_text, Colors.black, Colors.white),
          onPressed: () {
            // Handle message action
            _logger.info('Message button tapped for order: ${widget.order.id}');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds the tab bar with category tabs
  Widget _buildTabBar() {
    final List<String> tabNames = OrderTab.values.map((tab) {
      // Pass the item count for pluralization when it's the 'found' tab
      final itemCount =
          tab == OrderTab.found ? _orderItemsState.foundItems.length : null;
      return tab.displayName(itemCount: itemCount);
    }).toList();
    final List<int> itemCounts = [
      _orderItemsState.inProgressItems.length,
      _orderItemsState.customerReviewingItems.length,
      _orderItemsState.foundItems.length,
    ];

    return ProductControlTabs(
      categories: tabNames,
      itemCounts: itemCounts,
      selectedIndex: _selectedTab.index,
      onCategoryTap: (index) {
        setState(() {
          _selectedTab = OrderTab.values[index];
        });
      },
    );
  }

  /// Build the content for the selected tab
  Widget _buildTabContent() {
    // Get items for the selected tab
    final items = _orderItemsState.getItemsByTab(_selectedTab);

    // Add guidance overlay for the "En cours" tab
    if (_selectedTab == OrderTab.inProgress) {
      return Stack(
        children: [
          // Main content
          Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState()
                    : _buildAisleGroupedList(items),
              ),
            ],
          ),

          // Overlay - only show if _showGuidanceOverlay is true
          if (_showGuidanceOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Shopping list icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            size: 36,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'Voici votre liste de courses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Description
                        RichText(
                          text: const TextSpan(
                            text:
                                'Elle contient tous les articles de la commande du client. Marquez les articles comme trouvés au fur et à mesure en cliquant sur le bouton',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: ' "Voir détails".',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Got it button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showGuidanceOverlay = false;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Compris'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom action bar
          if (_selectedTab == OrderTab.inProgress && items.isEmpty)
            _buildBottomActionBar(items, selectedTab: _selectedTab),
        ],
      );
    }

    // For empty tabs, show the empty state
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // For other tabs with items, show the aisle-grouped list
    return _buildAisleGroupedList(items);
  }

  /// Builds the bottom action bar with either a continue button or time information
  Widget _buildBottomActionBar(List<OrderItem> items,
      {required OrderTab selectedTab}) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 34,
          top: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ButtonFactory.createAnimatedButton(
          context: context,
          onPressed: () {
            _logger.info('Continue button pressed');

            // If we're in the inProgress tab and it's empty, check if there are items in customerReviewing
            final customerReviewingItems =
                _orderItemsState.customerReviewingItems;

            if (customerReviewingItems.isNotEmpty) {
              // Show the customer reviewing dialog
              showCustomerReviewingDialog(
                      context: context,
                      itemsCount:
                          _orderItemsState.customerReviewingItems.length,
                      customerName: widget.order.customerName)
                  .then((result) {
                if (result == null) {
                  // User canceled the dialog
                  return;
                }

                switch (result) {
                  case CustomerReviewResponse.itemsExchanged:
                    _logger.info('Items have been exchanged');
                    // Handle items exchanged logic
                    break;
                  case CustomerReviewResponse.refundRequested:
                    _logger.info(
                        '${widget.order.customerName} requested a refund');
                    // Handle refund request logic
                    break;
                  case CustomerReviewResponse.waitingForResponse:
                    _logger.info(
                        'Waiting for ${widget.order.customerName} response');
                    // Handle waiting for response logic
                    break;
                  case CustomerReviewResponse.continueToPayment:
                    _logger.info(
                        'Continue to payment, ${widget.order.customerName} will be refunded');
                    // Handle continue to payment logic
                    break;
                }
                // If result is null, the user canceled the dialog
              });
              return; // Exit early to prevent default action
            } else {
              OrderProcessingInteractionService().handleOrderStartCheckout(
                  context, items, widget.order.customerName);
            }
          },
          text: 'Continuer',
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          splashColor: AppColors.primary,
          highlightColor: AppColors.primary,
          boxShadowColor: AppColors.primary,
          minWidth: double.infinity,
        ),
      ),
    );
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

    // List of widgets to display
    final List<Widget> allWidgets = [];

    // Add all aisle sections
    for (final aisle in sortedAisles) {
      final aisleItems = itemsByAisle[aisle]!;

      // Create a list of widgets for this aisle's items
      final List<Widget> aisleItemWidgets = [];

      // Generate item cards
      for (int i = 0; i < aisleItems.length; i++) {
        aisleItemWidgets.add(
          OrderItemCard(
            storeName: widget.order.storeName,
            item: aisleItems[i],
            onViewDetails: () {
              OrderProcessingInteractionService().handleOrderItemTap(
                context,
                aisleItems[i],
                widget.order,
              );
            },
          ),
        );
      }

      // Add aisle header and items to the main list
      allWidgets.add(_buildAisleHeader(aisle));
      allWidgets.addAll(aisleItemWidgets);
    }

    // Add "Ajouter un nouveau produit" button if we're in the first tab
    if (_selectedTab == OrderTab.inProgress) {
      allWidgets.add(
        _buildAddProductButton(),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: allWidgets,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == OrderTab.found
                  ? Icons.check_circle
                  : Icons.shopping_basket,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyListMessage(),
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            if (_selectedTab == OrderTab.inProgress) _buildAddProductButton(),
          ],
        ),
      ),
    );
  }

  // Get the appropriate empty list message based on the selected tab
  String _getEmptyListMessage() {
    switch (_selectedTab) {
      case OrderTab.inProgress:
        return 'Ajoutez les articles demandés par le client pendant vos achats ou continuez vers le paiement.';
      case OrderTab.customerReviewing:
        return 'Aucun article en attente de validation';
      case OrderTab.found:
        return 'Aucun article trouvé';
    }
  }

  Widget _buildAddProductButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Ajouter un nouveau produit',
              style: TextStyle(color: AppColors.primary, fontSize: 20),
            ),
          ),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }
}
