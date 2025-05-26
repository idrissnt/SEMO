import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/util/product_carousel.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/util/reward_message.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/util/util.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_card_footer.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_details_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';

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
          // if (order.isUrgent)
          //   OrderDetailsSection(order: order).buildUrgentTag(),
          // const SizedBox(width: 8),
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
            // information section
            SettingsSection(
              title: 'Informations détaillées',
              tag: order.isUrgent
                  ? OrderDetailsSection(order: order).buildUrgentTag()
                  : null,
              children: [
                CommunityOrderDetailsTile(
                  tag: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(order.storeLogoUrl),
                      ),
                      const SizedBox(width: 8),
                      Text(order.storeName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          )),
                    ],
                  ),
                  title: 'Le magasin',
                  subtitle:
                      'Adresse, heures de fermeture, distance, temps estimé',
                  icon: const Icon(
                    Icons.store,
                    color: Colors.white,
                  ),
                  iconContainerColor: AppColors.primary,
                  content: [
                    {'label': 'Adresse', 'value': order.storeAddress},
                    const {'label': 'Heures de fermeture', 'value': '18h'},
                    {
                      'label': 'Distance',
                      'value':
                          '${order.distanceKm.toStringAsFixed(1)} km de vous'
                    },
                    const {'label': 'Temps Estimé', 'value': '15 minutes'},
                  ],
                ),
                CommunityOrderDetailsTile(
                  title: 'Le client',
                  subtitle: 'Adresse, distance, temps estimé',
                  icon: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  iconContainerColor: Colors.green,
                  content: [
                    {'label': 'Adresse', 'value': order.deliveryAddress},
                    {
                      'label': 'Distance',
                      'value':
                          '${order.distanceKm.toStringAsFixed(1)} km de vous'
                    },
                    const {'label': 'Temps Estimé', 'value': '15 minutes'},
                  ],
                ),
                CommunityOrderDetailsTile(
                  title: 'La commande',
                  subtitle: 'Nombre de produits frais, date de livraison, note',
                  icon: const Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                  ),
                  iconContainerColor: Colors.red,
                  content: [
                    {
                      'label': 'Nombre de produits frais',
                      'value': '2/${order.totalItems}'
                    },
                    {'label': 'Date de livraison', 'value': order.deliveryTime},
                    {'label': 'Notes', 'value': order.notes},
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Product Images Carousel
            if (order.productImageUrls.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Produits commandés',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      const Spacer(),
                      OrderCardFooter(
                        order: order,
                      ).buildReward()
                    ],
                  ),
                  const SizedBox(height: 12),
                  ProductCarousel(imageUrls: order.productImageUrls),
                  const SizedBox(height: 24),
                ],
              ),
            const RewardMessage(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
