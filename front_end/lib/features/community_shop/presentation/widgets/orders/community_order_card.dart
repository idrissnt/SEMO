import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_card_footer.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_card_header.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_details_section.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/product_images_display.dart';
import 'package:semo/features/community_shop/presentation/widgets/shared/for_card.dart';

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
    return buildCard(
      onTap: () {},
      storeName: order.storeName,
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
            onPress: onTap,
          ),
        ],
      ),
    );
  }
}
