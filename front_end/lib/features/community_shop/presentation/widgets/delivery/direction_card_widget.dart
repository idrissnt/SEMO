import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/utils/address_copy.dart';

import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

class DirectionCardWidget extends StatelessWidget {
  final CommunityOrder order;

  const DirectionCardWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.directions, color: Colors.black),
            const SizedBox(width: 8),
            const Text(
              'Itinéraire de livraison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${order.distanceKm.toStringAsFixed(1)} km',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressRow(
                  icon: Icons.store,
                  title: order.storeName,
                  address: order.storeAddress,
                  color: AppColors.primary,
                  context: context,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      color: Colors.grey,
                      thickness: 1,
                      width: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildAddressRow(
                  icon: Icons.home,
                  title: order.customerName,
                  address: order.deliveryAddress,
                  color: Colors.red,
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: 'Copier l\'adresse',
          onPressed: () => copyAddressToClipboard(context, address),
        ),
      ],
    );
  }
}
