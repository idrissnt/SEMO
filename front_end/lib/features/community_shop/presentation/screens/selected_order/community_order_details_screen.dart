import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SizedBox;
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/components/datail_section.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/components/order_locations_map.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/components/product_carousel.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/components/reward_message.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

class CommunityOrderDetailsScreen extends StatelessWidget {
  final CommunityOrder order;

  const CommunityOrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Details de la commande',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          buildIcon(
            iconColor: Colors.white,
            backgroundColor: Colors.orange,
            icon: CupertinoIcons.hourglass,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Carousel
            if (order.productImageUrls.isNotEmpty)
              ProductCarousel(order: order),
            const SizedBox(height: 24),

            DetailSection(order: order),
            const SizedBox(height: 12),

            const RewardMessage(),
            const SizedBox(height: 24),

            // Map showing locations of store and customer
            OrderLocationsMap(order: order),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
