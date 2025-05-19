import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/utils/action_icon_button.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// //===========================================================================
/// Widget that displays the action icons (cart, notifications, profile) in the app bar
/// //===========================================================================

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
          child: _buildIcon(
            isScrolled: true,
            icon: CupertinoIcons.bell_fill,
            iconColor: Colors.white,
            backgroundColor: Colors.red,
            onPressed: () {
              // Handle notifications tap
            },
          ),
        ),
        const SizedBox(width: 10),
        // Cart icon
        _buildCartIconWithBadge(),
        const SizedBox(width: 10),
        // Profile icon
        _buildIcon(
          icon: CupertinoIcons.person_fill,
          iconColor: Colors.white,
          backgroundColor: AppColors.primary,
          onPressed: () {
            context.pushNamed(ProfileRouteNames.profile);
          },
        ),
      ],
    );
  }

  _buildIcon({
    bool isScrolled = false,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(0),
      height: isScrolled ? 35 * (1.0 - scrollProgress.clamp(0.0, 1.0)) : 35,
      width: isScrolled ? 35 * (1.0 - scrollProgress.clamp(0.0, 1.0)) : 35,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ActionIconButton(
        icon: icon,
        color: iconColor,
        onPressed: onPressed,
        size: isScrolled
            ? AppIconSize.xl * (1.0 - scrollProgress.clamp(0.0, 1.0))
            : AppIconSize.xl,
      ),
    );
  }

  Widget _buildCartIconWithBadge() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        _buildIcon(
          icon: CupertinoIcons.cart_fill,
          iconColor: Colors.white,
          backgroundColor: Colors.green,
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
