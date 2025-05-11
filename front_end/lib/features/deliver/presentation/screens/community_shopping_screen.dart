import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/deliver/presentation/test_data/community_orders.dart';
import 'package:semo/features/deliver/presentation/widgets/filters/quick_filters.dart';
import 'package:semo/features/deliver/presentation/widgets/orders/community_order_card.dart';

/// A screen that displays available community shopping orders
/// that users can pick up for their neighbors.
class CommunityShoppingScreen extends StatefulWidget {
  const CommunityShoppingScreen({Key? key}) : super(key: key);

  @override
  State<CommunityShoppingScreen> createState() => _CommunityShoppingScreenState();
}

class _CommunityShoppingScreenState extends State<CommunityShoppingScreen> {
  final AppLogger _logger = AppLogger();
  late List<CommunityOrder> _allOrders;
  late List<CommunityOrder> _filteredOrders;
  final Map<String, dynamic> _filterValues = {};

  @override
  void initState() {
    super.initState();
    _logger.debug('CommunityShoppingScreen: Initializing');
    _allOrders = getSampleCommunityOrders();
    _filteredOrders = List.from(_allOrders);
  }

  /// Filter orders based on filter values
  void _filterOrders(Map<String, dynamic> filters) {
    setState(() {
      _filterValues.clear();
      _filterValues.addAll(filters);

      if (filters.isEmpty) {
        _filteredOrders = List.from(_allOrders);
        return;
      }

      _filteredOrders = _allOrders.where((order) {
        // Check all markets filter (default)
        if (filters['all_markets'] == true) {
          // Apply other filters but don't filter by store
        }
        // Check specific market filter
        else if (filters.containsKey('one_market')) {
          String selectedStore = filters['one_market'];
          if (order.storeName != selectedStore) {
            return false; // Skip if not from selected store
          }
        }

        // Check urgent filter
        if (filters['urgent'] == true && !order.isUrgent) {
          return false;
        }

        // Check distance filter
        if (filters.containsKey('distance')) {
          double maxDistance = filters['distance'];
          if (order.distanceKm > maxDistance) {
            return false;
          }
        }

        // Check scheduled filter
        if (filters.containsKey('scheduled')) {
          String schedule = filters['scheduled'];
          // This would typically check the delivery time against the schedule
          // For demo, we'll just check if it contains the schedule text
          if (!order.deliveryTime.contains(schedule)) {
            return false;
          }
        }

        // Check high reward filter
        if (filters['high_reward'] == true && order.reward < 4.0) {
          return false;
        }

        return true; // Include order if it passes all filters
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickFilters(),
            Expanded(
              child: _filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return CommunityOrderCard(
                          order: _filteredOrders[index],
                          onTap: () => _handleOrderTap(_filteredOrders[index]),
                          onAccept: () => _handleOrderAccept(_filteredOrders[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header with title and map button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Courses Solidaires',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openMapView,
            icon: const Icon(Icons.map, color: AppColors.primary),
            label: const Text('Carte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.primary),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the quick filters section
  Widget _buildQuickFilters() {
    return QuickFilters(
      initialFilters: _filterValues,
      onFiltersChanged: _filterOrders,
      autoSelectAllMarkets: true,
    );
  }

  /// Builds the empty state when no orders match the filters
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterValues.isEmpty
                ? 'Revenez plus tard pour aider vos voisins'
                : 'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the map view of available orders
  void _openMapView() {
    _logger.info('Opening map view');
    // This would navigate to a map view screen
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Carte des commandes à proximité'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handles tapping on an order
  void _handleOrderTap(CommunityOrder order) {
    _logger.info('Order tapped: ${order.id}');
    // This would navigate to an order detail screen
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de la commande de ${order.customerName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handles accepting an order
  void _handleOrderAccept(CommunityOrder order) {
    _logger.info('Order accepted: ${order.id}');
    // This would add the order to the user's accepted orders
    // For now, we'll just show a snackbar and remove it from the list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous avez accepté la commande de ${order.customerName}'),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _allOrders.removeWhere((o) => o.id == order.id);
      _filterOrders(_filterValues);
    });
  }
}
