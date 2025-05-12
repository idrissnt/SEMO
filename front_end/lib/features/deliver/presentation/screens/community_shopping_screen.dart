import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/deliver/presentation/test_data/community_orders.dart';
import 'package:semo/features/deliver/presentation/widgets/filters/quick_filters.dart';
import 'package:semo/features/deliver/presentation/widgets/orders/community_order_card.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/location_section.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/utils/action_icon_button.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// A screen that displays available community shopping orders
/// that users can pick up for their neighbors.
class CommunityShoppingScreen extends StatefulWidget {
  const CommunityShoppingScreen({Key? key}) : super(key: key);

  @override
  State<CommunityShoppingScreen> createState() =>
      _CommunityShoppingScreenState();
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
          var storeData = filters['one_market'];
          String selectedStore;

          if (storeData is Map<String, dynamic> &&
              storeData.containsKey('name')) {
            selectedStore = storeData['name'];
          } else if (storeData is String) {
            selectedStore = storeData; // For backward compatibility
          } else {
            return false; // Invalid store data
          }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildQuickFilters(),
            const SizedBox(height: 4),
            Expanded(
              child: _filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredOrders.length + 1, // +1 for the title
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // First item is the title
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderTitle(
                                'Vous allez au magasin? ',
                                'Prenez le panier de votre voisin',
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        }
                        // Adjust index to account for the title
                        final orderIndex = index - 1;
                        return CommunityOrderCard(
                          order: _filteredOrders[orderIndex],
                          onTap: () =>
                              _handleOrderTap(_filteredOrders[orderIndex]),
                          onAccept: () =>
                              _handleOrderAccept(_filteredOrders[orderIndex]),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LocationSection(onLocationTap: () {}),
          // ElevatedButton.icon(
          //   onPressed: _openMapView,
          //   icon: const Icon(Icons.map, color: Colors.black),
          //   label: const Text(
          //     'Carte',
          //     style:
          //         TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.grey.shade300,
          //     foregroundColor: Colors.black,
          //     elevation: 0,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   ),
          // ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ActionIconButton(
                  icon: CupertinoIcons.cube_box_fill,
                  color: Colors.white,
                  onPressed: () {},
                  size: AppIconSize.xl,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(0),
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ActionIconButton(
                  icon: CupertinoIcons.person_fill,
                  color: Colors.white,
                  onPressed: () {
                    context.pushNamed(ProfileRouteNames.profile);
                  },
                  size: AppIconSize.xl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // build the order title
  Widget _buildOrderTitle(String titleOne, String titleTwo) {
    return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green,
              Colors.red,
              AppColors.primary,
              Colors.yellow.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.thirdColor,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: Colors.black)),
                child: Text(
                  titleOne,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Container(
                margin: const EdgeInsets.only(left: 25),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  titleTwo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ));
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
