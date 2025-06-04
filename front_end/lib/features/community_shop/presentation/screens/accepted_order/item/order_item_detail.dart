import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/initial_screen/utils/models.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/util/start_button.dart';
import 'package:semo/features/community_shop/presentation/screens/widgets/icon_button.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

class CommunityOrderItemDetailsScreen extends StatelessWidget {
  final OrderItem orderItem;
  final CommunityOrder order;

  const CommunityOrderItemDetailsScreen({
    Key? key,
    required this.orderItem,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final heroTag = 'product-image-${orderItem.id}_item_details';
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top image with overlay buttons
            Stack(
              children: [
                // Main image with hero animation and click handler
                GestureDetector(
                  onTap: () {
                    // Navigate to full-screen image viewer
                    OrderProcessingInteractionService().handleImageViewer(
                      context,
                      orderItem,
                      order,
                      heroTag: heroTag,
                    );
                  },
                  child: SizedBox(
                    width: size.width,
                    height: size.height * 0.4, // 40% of screen height
                    child: Hero(
                      tag: heroTag,
                      child: Image.network(
                        orderItem.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top, // Status bar height
                  left: 16,
                  child: IconButton(
                    icon: buildIconButton(
                        Icons.arrow_back_ios_new, Colors.black, Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),

                // message button
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  right: 16,
                  child: IconButton(
                    icon: buildIconButton(CupertinoIcons.chat_bubble_text,
                        Colors.black, Colors.white),
                    onPressed: () {
                      // Handle share action
                    },
                  ),
                ),

                // Image counter
                Positioned(
                  bottom: 30,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '1/1',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),

            // Use Stack with positioning instead of negative margins
            Transform.translate(
              offset: const Offset(0, -15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        '${orderItem.quantity} x ${orderItem.name}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location and details
                      _buildindicatorItem(
                          '${orderItem.aisle} - ${orderItem.position}'),

                      const SizedBox(height: 16),

                      // Quantity and price info
                      Row(
                        children: [
                          _buildInfoItem(
                              Icons.shopping_basket,
                              iconColor: Colors.green,
                              '${orderItem.quantity} ${orderItem.unit}'),
                          const SizedBox(width: 20),
                          _buildInfoItem(
                              Icons.euro,
                              iconColor: Colors.red,
                              orderItem.price.toStringAsFixed(2)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Divider(thickness: 1, color: Colors.grey),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ButtonFactory.createAnimatedButton(
                          context: context,
                          onPressed: () {
                            OrderProcessingInteractionService()
                                .handleOrderItemFound(
                                    context, orderItem, order);
                          },
                          text: 'Produit trouvé',
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                          splashColor: AppColors.primary,
                          highlightColor: AppColors.primary,
                          boxShadowColor: AppColors.primary,
                          minWidth: double.infinity,
                        ),
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ButtonFactory.createAnimatedButton(
                          context: context,
                          onPressed: () {
                            OrderProcessingInteractionService()
                                .handleOrderItemNotFound(
                                    context, orderItem, order);
                          },
                          text: 'Produit indisponible',
                          backgroundColor: AppColors.secondary,
                          textColor: Colors.black,
                          splashColor: AppColors.secondary,
                          highlightColor: AppColors.secondary,
                          boxShadowColor: AppColors.secondary,
                          minWidth: double.infinity,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nous ferons savoir à ${order.customerName} que le produit est indisponible.',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: 300,
                        height: 37,
                        child: CommunityOrderButton(
                          textColor: AppColors.textPrimaryColor,
                          backgroundColor: AppColors.secondary,
                          textSize: 14,
                          text: 'Envoyer un message à ${order.customerName}',
                          showIcon: false,
                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildindicatorItem(String text) {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: Colors.blue),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}
