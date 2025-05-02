import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// Tab for app settings and support
class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Settings
          const SettingsSection(
            title: 'App Settings',
            children: [
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Push, email, in-app notifications',
                routeName: ProfileRouteNames.notifications,
              ),
              SettingsTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'Change app language',
                routeName: ProfileRouteNames.language,
              ),
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Appearance',
                subtitle: 'Dark mode, theme settings',
                routeName: ProfileRouteNames.appearance,
              ),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: 'Control your data and privacy settings',
                routeName: ProfileRouteNames.privacy,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Support & About
          const SettingsSection(
            title: 'Support & About',
            children: [
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'FAQs, contact support',
                routeName: ProfileRouteNames.help,
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version, terms, privacy policy',
                routeName: ProfileRouteNames.about,
              ),
              SettingsTile(
                icon: Icons.star_outline,
                title: 'Rate the App',
                subtitle: 'Tell us what you think',
                routeName: ProfileRouteNames.rate,
              ),
              SettingsTile(
                icon: Icons.share_outlined,
                title: 'Share with Friends',
                subtitle: 'Invite others to join',
                routeName: ProfileRouteNames.share,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Version info
          _buildVersionInfo(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            width: 60,
            height: 60,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.app_shortcut,
              size: 60,
              color: Color(0xFF9E9E9E), // Colors.grey
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SEMO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 SEMO Inc. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
