import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
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
          child: buildIcon(
            scrollProgress: scrollProgress,
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
        buildIcon(
          scrollProgress: scrollProgress,
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

  Widget _buildCartIconWithBadge() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        buildIcon(
          scrollProgress: scrollProgress,
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
