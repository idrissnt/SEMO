import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/initial_screen/utils/models.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

class ImageCard extends StatelessWidget {
  final OrderItem item;
  final CommunityOrder order;

  const ImageCard({Key? key, required this.item, required this.order})
      : super(key: key);

  void _selectItem(OrderItem item, BuildContext context) {
    _logger.info('Item selected: ${item.id}');
    // Navigate to the item found screen with the selected replacement
    OrderProcessingInteractionService().handleOrderItemFound(
      context,
      item,
      order,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String heroTag = 'product-image-${item.id}_image_card';

    return GestureDetector(
      onTap: () {
        // Navigate to full-screen image viewer
        _logger.info('Image clicked: ${item.id}');
        OrderProcessingInteractionService().handleImageViewer(
          context,
          item,
          order,
          heroTag: heroTag,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  // Product image with Hero animation
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(item.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  // add badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        _logger.info('Item selected: ${item.id}');
                        _selectItem(item, context);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.add, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Product title
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
                // Since we don't have price and unit as parameters, we'll show just the quantity
                Text(
                  '${item.price.toStringAsFixed(2)} € • ${item.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
