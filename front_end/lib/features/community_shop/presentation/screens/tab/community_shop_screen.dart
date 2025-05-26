import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/community_shop/presentation/screens/tab/components/community_header.dart';
import 'package:semo/features/community_shop/presentation/screens/tab/components/empty_orders_state.dart';
import 'package:semo/features/community_shop/presentation/services/order_filter_service.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/filters/quick_filters.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/community_order_card.dart';

/// A screen that displays available community shopping orders
/// that users can pick up for their neighbors.
class CommunityShopScreen extends StatefulWidget {
  const CommunityShopScreen({Key? key}) : super(key: key);

  @override
  State<CommunityShopScreen> createState() => _CommunityShopScreenState();
}

class _CommunityShopScreenState extends State<CommunityShopScreen> {
  final AppLogger _logger = AppLogger();
  late List<CommunityOrder> _allOrders;
  late List<CommunityOrder> _filteredOrders;
  final Map<String, dynamic> _filterValues = {};

  // Services
  final OrderInteractionService _orderInteractionService =
      OrderInteractionService();

  @override
  void initState() {
    super.initState();
    _logger.debug('CommunityShopScreen: Initializing');
    _allOrders = getSampleCommunityOrders();
    _filteredOrders = List.from(_allOrders);
  }

  /// Apply filters to the orders list
  void _filterOrders(Map<String, dynamic> filters) {
    setState(() {
      _filterValues.clear();
      _filterValues.addAll(filters);
      _filteredOrders = OrderFilterService.filterOrders(_allOrders, filters);
    });
  }

  /// Handle order acceptance
  void _handleOrderAccepted(CommunityOrder order) {
    setState(() {
      _allOrders.removeWhere((o) => o.id == order.id);
      _filterOrders(_filterValues);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with location and action buttons
            const CommunityHeader(),

            // Quick filters section
            QuickFilters(
              initialFilters: _filterValues,
              onFiltersChanged: _filterOrders,
              autoSelectAllMarkets: true,
            ),

            const SizedBox(height: 4),

            // Main content area
            Expanded(
              child: _filteredOrders.isEmpty
                  ? EmptyOrdersState(filterValues: _filterValues)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredOrders.length + 1, // +1 for the title
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // First item is the title banner
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Text(
                                  'Vous allez au magasin? Prenez le panier de votre voisin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          );
                        }

                        // Adjust index to account for the title
                        final orderIndex = index - 1;
                        final order = _filteredOrders[orderIndex];

                        return CommunityOrderCard(
                          order: order,
                          onTap: () => _orderInteractionService.handleOrderTap(
                              context, order),
                          onAccept: () =>
                              _orderInteractionService.handleOrderAccept(
                            context,
                            order,
                            _handleOrderAccepted,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
