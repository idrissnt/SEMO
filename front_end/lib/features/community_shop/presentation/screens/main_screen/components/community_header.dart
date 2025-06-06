import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';
import 'package:semo/features/community_shop/presentation/widgets/shared/large_text_button.dart';
import 'package:semo/features/message/routes/const.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/location_section.dart';

/// Header component for the community shopping screen
/// Displays location and action buttons
class CommunityHeader extends StatelessWidget {
  const CommunityHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // address section
          LocationSection(onLocationTap: () {}),
          // go to delivery screen button and message button
          Row(
            children: [
              // Shopper delivery button
              buildLargeTextButton(context, onTap: () {
                OrderInteractionService().handleShopperDelivery(context);
              },
                  count: 0,
                  text: 'Mes commandes',
                  iconColor: const Color.fromARGB(255, 248, 209, 36),
                  textColor: Colors.black,
                  showCount: true),
              const SizedBox(width: 8),
              // message button
              buildIcon(
                iconColor: Colors.white,
                backgroundColor: Colors.green,
                icon: CupertinoIcons.chat_bubble_text_fill,
                onPressed: () {
                  context.pushNamed(MessageRoutesConstants.message);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
