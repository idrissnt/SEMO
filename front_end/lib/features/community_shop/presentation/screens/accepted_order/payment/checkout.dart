import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

class CommunityOrderCheckoutScreen extends StatelessWidget {
  const CommunityOrderCheckoutScreen({
    Key? key,
    required this.orders,
  }) : super(key: key);

  final List<CommunityOrder> orders;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (orders.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.chat_bubble_text),
              onPressed: () {
                // Handle message action
              },
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const Text('Resumé'),
                _buildRecentOrders(orders),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(List<CommunityOrder> orders) {
    // Mock recent orders
    return SliverList.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${orders[index].totalItems} articles • ${(orders[index].totalPrice).toStringAsFixed(2)}€',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...orders[index]
                          .productImageUrls
                          .take(3)
                          .map((productImageUrl) => Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(productImageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(),
                      if (orders[index].productImageUrls.length > 3)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black,
                            shape: const CircleBorder(),
                            minimumSize: const Size(40, 40),
                          ),
                          child: Text(
                            '+${orders[index].productImageUrls.length - 3}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Paiement effectuer',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
