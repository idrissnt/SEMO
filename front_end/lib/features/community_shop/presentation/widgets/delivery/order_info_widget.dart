import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/initial_screen/utils/models.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/delivery/product_images_widget.dart';

class OrderInfoWidget extends StatelessWidget {
  final CommunityOrder order;
  final OrderItem orderItem;

  const OrderInfoWidget({
    Key? key,
    required this.order,
    required this.orderItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations supplémentaires',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ProductImagesWidget(order: order, orderItem: orderItem),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.access_time,
          title: 'Temps de livraison estimé',
          value: '10 minutes',
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.directions_car,
          title: 'Distance',
          value: '${order.distanceKm.toStringAsFixed(1)} km',
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.phone,
          title: 'Téléphone',
          value: 'Non disponible', // Phone number not available in the model
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          icon: Icons.comment,
          title: 'Instructions',
          value: order.notes.isNotEmpty
              ? order.notes
              : 'Aucune instruction spécifique',
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
