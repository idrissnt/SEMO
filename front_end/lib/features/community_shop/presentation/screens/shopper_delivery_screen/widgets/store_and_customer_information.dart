import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/utils/address_raw.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

Widget buildStoreAndCustomerInformation(
    {required CommunityOrder order,
    required BuildContext context,
    int flex = 2}) {
  return Expanded(
    flex: flex,
    child: Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store name and logo
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(order.storeLogoUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              order.storeName,
              style: const TextStyle(
                color: AppColors.textPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 0), // Explicit spacing control
        // Store address row
        buildAddressRow(
          order.storeAddress,
          context,
        ),
        // Divider
        Padding(
          padding: const EdgeInsets.only(left: 0),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom vertical line with circular endpoints
                SizedBox(
                  width: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top circle
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Vertical line
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.blue,
                      ),
                      // Bottom circle
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '10 min',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Customer name and home icon
        Row(
          children: [
            Container(
              height: 30,
              width: 30,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                order.customerName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Customer address row
        buildAddressRow(
          order.deliveryAddress,
          context,
        ),
      ],
    ),
  );
}
