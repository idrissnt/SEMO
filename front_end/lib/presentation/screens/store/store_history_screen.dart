import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/logger.dart';

class StoreHistoryScreen extends StatefulWidget {
  final String storeId;

  const StoreHistoryScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  State<StoreHistoryScreen> createState() => _StoreHistoryScreenState();
}

class _StoreHistoryScreenState extends State<StoreHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  final AppLogger _logger = AppLogger();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Must call super.build

    _logger.debug('Building StoreHistoryScreen for store: ${widget.storeId}');

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/store/${widget.storeId}'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Order history list (placeholder data)
                _buildOrderItem(
                  context,
                  orderId: 'ORD123456',
                  date: 'March 2, 2025',
                  total: 49.97,
                  items: 5,
                ),
                const Divider(),
                _buildOrderItem(
                  context,
                  orderId: 'ORD123455',
                  date: 'February 25, 2025',
                  total: 37.82,
                  items: 3,
                ),
                const Divider(),
                _buildOrderItem(
                  context,
                  orderId: 'ORD123451',
                  date: 'February 18, 2025',
                  total: 62.15,
                  items: 7,
                ),
                const Divider(),
                _buildOrderItem(
                  context,
                  orderId: 'ORD123450',
                  date: 'February 12, 2025',
                  total: 28.43,
                  items: 4,
                ),

                const SizedBox(height: 16),

                // View all orders button
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      _logger.debug('View all orders pressed');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text('View All Orders'),
                  ),
                ),

                const SizedBox(height: 32),

                // Frequently ordered section
                const Text(
                  'Frequently Ordered',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFrequentItem('Organic Bananas', 2.99,
                          'https://via.placeholder.com/80'),
                      _buildFrequentItem(
                          'Whole Milk', 3.49, 'https://via.placeholder.com/80'),
                      _buildFrequentItem('Organic Eggs', 4.99,
                          'https://via.placeholder.com/80'),
                      _buildFrequentItem('Sourdough Bread', 5.49,
                          'https://via.placeholder.com/80'),
                      _buildFrequentItem(
                          'Avocados', 6.99, 'https://via.placeholder.com/80'),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context, {
    required String orderId,
    required String date,
    required double total,
    required int items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #$orderId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$items items · \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _logger.debug('Reorder pressed for order: $orderId');
            },
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentItem(String name, double price, String imageUrl) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
