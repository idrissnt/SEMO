// information section
import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/util/title_details_section.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_details_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';

class DetailSection extends StatelessWidget {
  final CommunityOrder order;

  const DetailSection({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return // information section
        SettingsSection(
      title: 'Informations détaillées',
      titleColor: AppColors.textPrimaryColor,
      tag: order.isUrgent
          ? OrderDetailsSection(order: order).buildUrgentTag()
          : null,
      children: [
        TileDetailsSection(
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
          subtitle: 'Adresse, heures de fermeture, distance, temps estimé',
          icon: const Icon(
            Icons.store,
            color: Colors.white,
          ),
          iconContainerColor: AppColors.primary,
          content: [
            {'label': 'Adresse', 'value': order.storeAddress},
            const {
              'label': 'Horaire d\'ouverture',
              'value': '8h - 20h (fermé)'
              // TODO: add dynamic hours with fermé in red and ouvert in green
            },
            {
              'label': 'Distance',
              'value': '${order.distanceKm.toStringAsFixed(1)} km de vous'
            },
            const {'label': 'Temps estimé', 'value': '15 minutes'},
          ],
        ),
        TileDetailsSection(
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
              'value': '${order.distanceKm.toStringAsFixed(1)} km de vous'
            },
            const {'label': 'Temps Estimé', 'value': '15 minutes'},
          ],
        ),
        TileDetailsSection(
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
    );
  }
}
