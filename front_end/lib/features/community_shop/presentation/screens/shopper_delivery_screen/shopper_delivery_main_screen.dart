import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/domain/enums/order_state.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/widgets/action_button.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/widgets/app_bar.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/widgets/empty_content.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/widgets/order_details.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/widgets/store_and_customer_information.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/shared/for_card.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/community_shop/presentation/widgets/shared/large_text_button.dart';

final AppLogger _logger = AppLogger();

class ShopperDeliveryMainScreen extends StatefulWidget {
  const ShopperDeliveryMainScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ShopperDeliveryMainScreen> createState() =>
      _ShopperDeliveryMainScreenState();
}

class _ShopperDeliveryMainScreenState extends State<ShopperDeliveryMainScreen>
    with SingleTickerProviderStateMixin {
  // Store orders in state so we can update them
  late List<CommunityOrder> _orders;

  // Tab controller
  late TabController _tabController;

  // Service for order interactions
  late OrderInteractionService _orderInteractionService;

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
    _tabController = TabController(length: 2, vsync: this);
    // Initialize order interaction service
    _orderInteractionService = OrderInteractionService();
    _logger.info(
        'ShopperDeliveryMainScreen initialized with ${_orders.length} orders');
  }

  @override
  void dispose() {
    // Clean up resources
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get orders for each tab
    final inProgressOrders = _getOrdersByState(OrderState.inProgress);
    final scheduledOrders = _getOrdersByState(OrderState.scheduled);

    _logger.info(
        'Orders by state: En cours: ${inProgressOrders.length}, Programmées: ${scheduledOrders.length}');

    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: [
          // Tab bar header
          _buildTabHeader(inProgressOrders.length, scheduledOrders.length),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: In progress orders
                _buildOrdersList(scheduledOrders, 'Programmée'),

                // Tab 2: Scheduled orders
                _buildOrdersList(inProgressOrders, 'En cours'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(
      int inProgressOrdersLength, int scheduledOrdersLength) {
    return TabBar(
      unselectedLabelStyle: const TextStyle(
        color: Colors.black,
      ),
      controller: _tabController,
      labelColor: Colors.blue,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      indicatorColor: Colors.blue,
      tabs: [
        Tab(
          icon: Badge(
            backgroundColor: Colors.orange,
            label: Text('$scheduledOrdersLength',
                style: const TextStyle(color: Colors.white)),
            child: const Icon(Icons.event),
          ),
          text: ' ${scheduledOrdersLength > 1 ? 'Programmées' : 'Programmée'}',
        ),
        Tab(
          icon: Badge(
            backgroundColor: Colors.green,
            label: Text('$inProgressOrdersLength',
                style: const TextStyle(color: Colors.white)),
            child: const Icon(Icons.hourglass_empty),
          ),
          text: 'En cours',
        ),
      ],
    );
  }

  // Build a list of orders for a specific tab
  Widget _buildOrdersList(List<CommunityOrder> orders, String tabName) {
    if (orders.isEmpty) {
      return emptyContent(tabName);
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

        _logger.info(
            'Building orders list for address: $address, ${ordersAtAddress.length} orders');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store address header
            _buildGroupHeader(address, ordersAtAddress),
            // Orders at this address
            ...ordersAtAddress
                .map((order) => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: buildCard(
                        onTap: () {},
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
                                          order: order,
                                          flex: 3,
                                          context: context),
                                    ],
                                  ),
                                ],
                              ),
                              // Spacing between order info and action buttons
                              const SizedBox(height: 16),

                              // Conditionally display buttons based on delivery time and state
                              buildDeliveryActionButtons(
                                order: order,
                                onOrderStateChanged: (order) {
                                  _updateOrderState([order]);
                                },
                                onStartOrder: (order) {
                                  _orderInteractionService
                                      .handleOrderStart(context, [order]);
                                },
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

  Widget _buildGroupHeader(String address, List<CommunityOrder> orders) {
    _logger.info(
        'Building group header for address: $address, ${orders.length} orders');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (orders.length > 1) _buildStartGroupOrdersButton(orders),
        ],
      ),
    );
  }

  Widget _buildStartGroupOrdersButton(List<CommunityOrder> orders) {
    // Check if any orders are in progress
    bool areOrdersInProgress =
        orders.any((order) => order.state == OrderState.inProgress);

    return buildLargeTextButton(context, onTap: () {
      final List<CommunityOrder> updatedOrder = orders
          .map((order) => order.copyWith(state: OrderState.inProgress))
          .toList();
      _updateOrderState(updatedOrder);
      OrderInteractionService().handleOrderStart(context, orders);
    },
        text: areOrdersInProgress
            ? 'Continuer les ${orders.length}'
            : 'Commencer les ${orders.length}',
        iconColor: areOrdersInProgress ? Colors.red : Colors.blue,
        textColor: Colors.white,
        showCount: false);
  }

  // Method to update order state
  void _updateOrderState(List<CommunityOrder> updatedOrders) {
    setState(() {
      // Find the index of the order to update
      for (var order in updatedOrders) {
        final index =
            _orders.indexWhere((existingOrder) => existingOrder.id == order.id);
        if (index != -1) {
          // Replace the old order with the updated one
          _orders[index] = order;
          _logger.info('Order ${order.id} updated to state: ${order.state}');
        }
      }
    });
  }
}
