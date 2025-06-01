import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/message/routes/const.dart';
import 'package:semo/features/order/routes/const.dart';

// Action icons for the app bar

class ActionIcons extends StatelessWidget {
  final double scrollProgress;
  const ActionIcons({Key? key, required this.scrollProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Notifications icon
        Opacity(
          opacity: 1.0 - (scrollProgress * 2).clamp(0.0, 1.0),
          child: buildIcon(
            scrollProgress: scrollProgress,
            isScrolled: true,
            icon: CupertinoIcons.bell_fill,
            iconColor: Colors.white,
            backgroundColor: Colors.red,
            onPressed: () {
              context.pushNamed(OrderRoutesConstants.notificationName);
            },
          ),
        ),
        const SizedBox(width: 10),
        // Cart icon
        _buildCartIconWithBadge(),
        const SizedBox(width: 10),
        // Profile icon
        buildIcon(
          scrollProgress: scrollProgress,
          icon: CupertinoIcons.chat_bubble_text_fill,
          iconColor: Colors.white,
          backgroundColor: Colors.green,
          onPressed: () {
            context.pushNamed(MessageRoutesConstants.message);
          },
        ),
      ],
    );
  }

  Widget _buildCartIconWithBadge() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        buildIcon(
          scrollProgress: scrollProgress,
          icon: CupertinoIcons.cart_fill,
          iconColor: Colors.white,
          backgroundColor: AppColors.primary,
          onPressed: () {
            // Handle cart tap
          },
        ),
        // Cart badge
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
