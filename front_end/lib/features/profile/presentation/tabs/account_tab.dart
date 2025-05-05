import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';

import 'package:semo/features/profile/presentation/full_screen_bottom_sheet/personal_info_bottom_sheet.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// Tab for account-related settings
class AccountTab extends StatelessWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Settings
          SettingsSection(
            title: 'Account',
            children: [
              SettingsTile(
                title: 'Personal Information',
                subtitle: 'Name, email, phone number',
                onTap: () => _showPersonalInfoBottomSheet(context),
                icon: AppIcons.person(size: 24, color: Colors.white),
                iconContainerColor: AppColors.primary,
              ),
              SettingsTile(
                title: 'Security',
                subtitle: 'Password, verification, login activity',
                routeName: ProfileRouteNames.security,
                icon: AppIcons.security(size: 24, color: Colors.white),
                iconContainerColor: Colors.orange,
              ),
              SettingsTile(
                title: 'Payment Methods',
                subtitle: 'Credit cards, bank accounts',
                routeName: ProfileRouteNames.paymentMethods,
                icon: AppIcons.payment(size: 24, color: Colors.white),
                iconContainerColor: Colors.green,
              ),
              SettingsTile(
                title: 'Addresses',
                subtitle: 'Saved addresses for delivery and tasks',
                routeName: ProfileRouteNames.addresses,
                icon: AppIcons.location(size: 24, color: Colors.white),
                iconContainerColor: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper method to show the personal info bottom sheet
  void _showPersonalInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // Enable dragging to dismiss
      isDismissible: true, // Allow dismissing by tapping outside
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95, // Start at 95% of screen height
        minChildSize: 0.5, // Allow dragging down to 50%
        maxChildSize: 0.95, // Maximum 95% of screen height
        expand: false,
        builder: (context, scrollController) =>
            PersonalInfoBottomSheet(scrollController: scrollController),
      ),
    );
  }
}
