import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/icons/icon_with_container.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/location_section.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

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
          LocationSection(onLocationTap: () {}),
          Row(
            children: [
              buildIcon(
                radius: 24,
                iconSize: 20,
                iconColor: AppColors.iconColorFirstColor,
                backgroundColor: AppColors.searchBarColor,
                icon: CupertinoIcons.search,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              buildIcon(
                iconColor: Colors.white,
                backgroundColor: Colors.orange,
                icon: Icons.shopping_bag,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              buildIcon(
                iconColor: Colors.white,
                backgroundColor: AppColors.primary,
                icon: CupertinoIcons.person_fill,
                onPressed: () {
                  context.pushNamed(ProfileRouteNames.profile);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
