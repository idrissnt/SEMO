import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/components/datail_section.dart';
// import 'package:semo/features/community_shop/presentation/screens/selected_order/components/order_locations_map.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/components/product_carousel.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/components/reward_message.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/util/start_button.dart';
import 'package:semo/features/community_shop/presentation/services/delivery_time_service.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
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
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Scrollbar(
            controller: ScrollController(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images Carousel
                  if (order.productImageUrls.isNotEmpty)
                    ProductCarousel(order: order),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DetailSection(order: order),
                  ),
                  const SizedBox(height: 12),

                  const RewardMessage(),
                  const SizedBox(height: 12),

                  // Map showing locations of store and customer
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //   child: OrderLocationsMap(order: order),
                  // ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 24, top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Add to cart button
                  SizedBox(
                    // width: 190,
                    height: 50,
                    child: CommunityOrderButton(
                      textColor: AppColors.textSecondaryColor,
                      backgroundColor: AppColors.primary,
                      textSize: AppFontSize.large,
                      showIcon: false,
                      text: 'Commencer maintenant',
                      onPressed: () {
                        OrderInteractionService().handleOrderStart(
                          context,
                          [order],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    // width: 170,
                    height: 50,
                    child: CommunityOrderButton(
                      textColor: AppColors.textPrimaryColor,
                      backgroundColor: AppColors.secondary,
                      textSize: AppFontSize.large,
                      text: 'Programmer',
                      showIcon: true,
                      onPressed: () {
                        DeliveryTimeService().showDeliveryTimePicker(
                          context: context,
                          order: order,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
