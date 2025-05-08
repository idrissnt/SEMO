import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/home/presentation/widgets/app_bar/utils/action_icon_button.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// //===========================================================================
/// Widget that displays the action icons (cart, notifications, profile) in the app bar
/// //===========================================================================

// Action icons for the app bar

class ActionIcons extends StatelessWidget {
  const ActionIcons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cart icon
        Container(
          padding: const EdgeInsets.all(0),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ActionIconButton(
            icon: CupertinoIcons.cart_fill,
            color: Colors.white,
            onPressed: () {
              // Handle cart tap
            },
            size: 24,
          ),
        ),
        const SizedBox(width: 10),
        // Notifications icon
        Container(
          padding: const EdgeInsets.all(0),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ActionIconButton(
            icon: CupertinoIcons.bell_fill,
            color: Colors.white,
            onPressed: () {
              // Handle notifications tap
            },
            size: 24,
          ),
        ),
        const SizedBox(width: 10),
        // Profile icon
        Container(
          padding: const EdgeInsets.all(0),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ActionIconButton(
            icon: CupertinoIcons.person_fill,
            color: Colors.white,
            onPressed: () {
              context.pushNamed(ProfileRouteNames.profile);
            },
            size: AppIconSize.xl,
          ),
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
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(0),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ActionIconButton(
            icon: CupertinoIcons.person_fill,
            color: Colors.white,
            onPressed: () {
              context.pushNamed(ProfileRouteNames.profile);
            },
            size: AppIconSize.xl,
          ),
        )
      ],
    );
  }

  /// Creates a cart icon with a notification badge
  Widget _buildCartIconWithBadge() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ActionIconButton(
            icon: CupertinoIcons.cart_fill,
            color: Colors.white,
            onPressed: () {
              // Handle cart tap
            },
            size: AppIconSize.xl,
          ),
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
