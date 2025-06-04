import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/domain/enums/order_state.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/widgets/action_button.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/widgets/app_bar.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/widgets/order_details.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/widgets/order_state_badge.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/widgets/store_and_customer_information.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/shared/for_card.dart';
import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

class GroupOrdersScreen extends StatefulWidget {
  const GroupOrdersScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<GroupOrdersScreen> createState() => _GroupOrdersScreenState();
}

class _GroupOrdersScreenState extends State<GroupOrdersScreen>
    with SingleTickerProviderStateMixin {
  // Store orders in state so we can update them
  late List<CommunityOrder> _orders;

  // Tab controller
  late TabController _tabController;

  // Get orders filtered by state
  List<CommunityOrder> _getOrdersByState(OrderState state) {
    return _orders.where((order) => order.state == state).toList();
  }

  // Map to group orders by store address
  Map<String, List<CommunityOrder>> get groupedOrders {
    final Map<String, List<CommunityOrder>> result = {};

    for (var order in _orders) {
      if (result.containsKey(order.storeAddress)) {
        result[order.storeAddress]!.add(order);
      } else {
        result[order.storeAddress] = [order];
      }
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    // Initialize orders from sample data
    _orders = getSampleCommunityOrders();
    // Initialize tab controller with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    _logger.info('GroupOrdersScreen initialized with ${_orders.length} orders');
  }

  @override
  void dispose() {
    // Clean up resources
    _tabController.dispose();
    super.dispose();
  }

  // Build a list of orders for a specific tab
  Widget _buildOrdersList(List<CommunityOrder> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Aucune commande dans cette catégorie',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // Group orders by store address
    final Map<String, List<CommunityOrder>> grouped = {};
    for (var order in orders) {
      if (grouped.containsKey(order.storeAddress)) {
        grouped[order.storeAddress]!.add(order);
      } else {
        grouped[order.storeAddress] = [order];
      }
    }

    final addresses = grouped.keys.toList();

    return ListView.builder(
      itemCount: addresses.length,
      itemBuilder: (context, addressIndex) {
        final address = addresses[addressIndex];
        final ordersAtAddress = grouped[address]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store address header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${ordersAtAddress.length} commande${ordersAtAddress.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Orders at this address
            ...ordersAtAddress
                .map((order) => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                      child: buildCard(
                        storeName: order.storeName,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  // Order details
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left column - Store information
                                      buildStoreAndCustomerInformation(
                                          order: order,
                                          context: context,
                                          flex: 2),
                                      const SizedBox(width: 8),

                                      // Right column - Order information
                                      buildOrderInformation(
                                          order: order, flex: 3),
                                    ],
                                  ),
                                ],
                              ),
                              // Spacing between order info and action buttons
                              const SizedBox(height: 16),

                              // Conditionally display buttons based on delivery time and state
                              buildDeliveryActionButtons(
                                order: order,
                                onOrderStateChanged: _updateOrderState,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),

            // Divider between address groups
            if (addressIndex < addresses.length - 1)
              const Divider(
                  height: 32, thickness: 1, indent: 16, endIndent: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get orders for each tab
    final enAttenteOrders = _getOrdersByState(OrderState.enAttente);
    final enCoursOrders = _getOrdersByState(OrderState.enCours);
    final programmerOrders = _getOrdersByState(OrderState.programmer);

    _logger.info(
        'Orders by state: En attente: ${enAttenteOrders.length}, En cours: ${enCoursOrders.length}, Programmées: ${programmerOrders.length}');

    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                icon: Badge(
                  backgroundColor: Colors.blue,
                  label: Text('${enAttenteOrders.length}',
                      style: const TextStyle(color: Colors.white)),
                  child: const Icon(Icons.hourglass_empty),
                ),
                text: 'En attente',
              ),
              Tab(
                icon: Badge(
                  backgroundColor: Colors.green,
                  label: Text('${enCoursOrders.length}',
                      style: const TextStyle(color: Colors.white)),
                  child: const Icon(Icons.delivery_dining),
                ),
                text: 'En cours',
              ),
              Tab(
                icon: Badge(
                  backgroundColor: Colors.orange,
                  label: Text('${programmerOrders.length}',
                      style: const TextStyle(color: Colors.white)),
                  child: const Icon(Icons.event),
                ),
                text: 'Programmées',
              ),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: En attente orders
                _buildOrdersList(enAttenteOrders),

                // Tab 2: En cours orders
                _buildOrdersList(enCoursOrders),

                // Tab 3: Programmées orders
                _buildOrdersList(programmerOrders),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to update order state
  void _updateOrderState(CommunityOrder updatedOrder) {
    setState(() {
      // Find the index of the order to update
      final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
      if (index != -1) {
        // Replace the old order with the updated one
        _orders[index] = updatedOrder;
        _logger.info(
            'Order ${updatedOrder.id} updated to state: ${updatedOrder.state}');
      }
    });
  }
}
