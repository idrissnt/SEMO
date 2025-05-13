import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/location_section.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/utils/action_icon_button.dart';
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
              Container(
                padding: const EdgeInsets.all(0),
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ActionIconButton(
                  icon: CupertinoIcons.hourglass,
                  color: Colors.white,
                  onPressed: () {},
                  size: AppIconSize.xl,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(0),
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: AppColors.primary,
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
          ),
        ],
      ),
    );
  }
}
