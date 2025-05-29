import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_card_footer.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_card_header.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_details_section.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/product_images_display.dart';

/// A card widget that displays a community shopping order
/// with product images, customer information, and action buttons.
class CommunityOrderCard extends StatelessWidget {
  /// The community order to display
  final CommunityOrder order;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  const CommunityOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The order card
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  order.storeName.toLowerCase().contains('lec')
                      ? Colors.blue.withValues(alpha: 0.4)
                      : order.storeName.toLowerCase().contains('car')
                          ? const Color.fromARGB(255, 249, 47, 47)
                              .withValues(alpha: 0.4)
                          : const Color.fromARGB(255, 255, 196, 0)
                              .withValues(alpha: 0.4), // Top (blue)

                  order.storeName.toLowerCase().contains('lec')
                      ? Colors.blue.withValues(alpha: 0.4)
                      : order.storeName.toLowerCase().contains('car')
                          ? const Color.fromARGB(255, 249, 47, 47)
                              .withValues(alpha: 0.4)
                          : const Color.fromARGB(255, 255, 196, 0)
                              .withValues(alpha: 0.4), // Top-right (red)

                  Colors.white, // Right (white)
                  Colors.white, // Bottom-right (white)
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(20), // Slightly larger radius
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header section with store info and distance
                OrderCardHeader(order: order, onTap: onTap),

                // Main content section with product images and order details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product images display
                      ProductImagesDisplay(
                        productImageUrls: order.productImageUrls,
                      ),
                      const SizedBox(width: 4),
                      // Order details section
                      Expanded(
                        child: OrderDetailsSection(order: order),
                      ),
                    ],
                  ),
                ),

                // Footer section with reward and action button
                OrderCardFooter(
                  order: order,
                  onAccept: onTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
