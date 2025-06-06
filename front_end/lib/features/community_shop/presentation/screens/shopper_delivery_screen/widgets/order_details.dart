import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/shared/for_card.dart';
import 'package:semo/features/message/routes/const.dart';

Widget buildOrderInformation({
  required CommunityOrder order,
  int flex = 3,
  required BuildContext context,
}) {
  return Expanded(
    flex: flex, // Takes 3 parts of the available space (more than left column)
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Reward row and message button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Reward row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.sackDollar,
                      size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${order.reward.toStringAsFixed(1)}€',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            // Message button
            buildIcon(
              iconSize: 20,
              containerSize: 28,
              iconColor: Colors.white,
              backgroundColor: Colors.green,
              icon: CupertinoIcons.chat_bubble_text_fill,
              onPressed: () {
                context.pushNamed(MessageRoutesConstants.message);
              },
            ),
          ],
        ),

        const SizedBox(height: 12),
        // Order details
        Container(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.textPrimaryColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInfoRow(
                Icons.shopping_basket,
                '${order.totalItems} articles (10 Unités)',
                Colors.green,
              ),
              const SizedBox(height: 4),
              buildInfoRow(
                Icons.euro,
                '${order.totalPrice.toStringAsFixed(2)}€ de courses',
                Colors.red,
              ),
              const SizedBox(height: 4),
              buildInfoRow(
                Icons.schedule,
                order.deliveryTime,
                Colors.blue,
              ),
              const SizedBox(height: 4),
              if (order.isUrgent) buildUrgentTag(),
            ],
          ),
        )
      ],
    ),
  );
}
