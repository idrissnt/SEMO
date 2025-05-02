import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/home/presentation/widgets/app_bar/utils/action_icon_button.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// //===========================================================================
/// Widget that displays the action icons (cart, notifications, profile) in the app bar
/// //===========================================================================

final AppLogger logger = AppLogger();

class ActionIcons extends StatelessWidget {
  const ActionIcons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cart icon
        Padding(
          padding: const EdgeInsets.all(0),
          child: ActionIconButton(
            icon: Icons.shopping_cart_outlined,
            onPressed: () {
              // Handle cart tap
            },
            size: AppIconSize.xl,
          ),
        ),
        // Notifications icon
        Padding(
          padding: const EdgeInsets.all(0),
          child: ActionIconButton(
            icon: Icons.notifications_none_outlined,
            onPressed: () {
              // Handle notifications tap
            },
            size: AppIconSize.xl,
          ),
        ),
        // Profile icon
        ActionIconButton(
          icon: Icons.person_outline,
          onPressed: () {
            context.pushNamed(ProfileRouteNames.profile);
          },
          size: AppIconSize.xl,
        ),
      ],
    );
  }
}

/// //===========================================================================
/// Widget that displays the cart icon with badge and profile icon
/// Used in the collapsed app bar state
/// //===========================================================================

class CartProfileIcon extends StatelessWidget {
  const CartProfileIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildCartIconWithBadge(),
        const SizedBox(width: 0),
        ActionIconButton(
          icon: Icons.person_outline,
          color: Colors.grey[800],
          onPressed: () {
            context.pushNamed(ProfileRouteNames.profile);
          },
          size: AppIconSize.xl,
        )
      ],
    );
  }

  /// Creates a cart icon with a notification badge
  Widget _buildCartIconWithBadge() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ActionIconButton(
          icon: Icons.shopping_cart_outlined,
          color: Colors.grey[800],
          onPressed: () {
            // Handle cart tap
          },
          size: AppIconSize.xl,
        ),
        // Cart badge
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.green,
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
