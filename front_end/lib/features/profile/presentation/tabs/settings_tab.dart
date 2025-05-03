import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
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
          SettingsSection(
            title: 'App Settings',
            children: [
              SettingsTile(
                icon: AppIcons.notifications(size: 24, color: Colors.white),
                iconContainerColor: Colors.green,
                title: 'Notifications',
                subtitle: 'Push, email, in-app notifications',
                routeName: ProfileRouteNames.notifications,
              ),
              SettingsTile(
                icon: AppIcons.language(size: 24, color: Colors.white),
                iconContainerColor: Colors.blue,
                title: 'Language',
                subtitle: 'Change app language',
                routeName: ProfileRouteNames.language,
              ),
              SettingsTile(
                icon: AppIcons.darkMode(size: 24, color: Colors.white),
                iconContainerColor: Colors.grey,
                title: 'Appearance',
                subtitle: 'Dark mode, theme settings',
                routeName: ProfileRouteNames.appearance,
              ),
              SettingsTile(
                icon: AppIcons.privacy(size: 24, color: Colors.white),
                iconContainerColor: Colors.orange,
                title: 'Privacy',
                subtitle: 'Control your data and privacy settings',
                routeName: ProfileRouteNames.privacy,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Support & About
          SettingsSection(
            title: 'Support & About',
            children: [
              SettingsTile(
                icon: AppIcons.help(size: 24, color: Colors.white),
                iconContainerColor: Colors.green,
                title: 'Help Center',
                subtitle: 'FAQs, contact support',
                routeName: ProfileRouteNames.help,
              ),
              SettingsTile(
                icon: AppIcons.info(size: 24, color: Colors.white),
                iconContainerColor: Colors.blue,
                title: 'About',
                subtitle: 'App version, terms, privacy policy',
                routeName: ProfileRouteNames.about,
              ),
              SettingsTile(
                icon: AppIcons.star(size: 24, color: Colors.white),
                iconContainerColor: Colors.amber,
                title: 'Rate the App',
                subtitle: 'Tell us what you think',
                routeName: ProfileRouteNames.rate,
              ),
              SettingsTile(
                icon: AppIcons.share(size: 24, color: Colors.white),
                iconContainerColor: Colors.orange,
                title: 'Share with Friends',
                subtitle: 'Invite others to join',
                routeName: ProfileRouteNames.share,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildLogoutButton(context),

          const SizedBox(height: 24),

          // Version info
          _buildVersionInfo(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle logout
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Close the dialog
                    context.pop();
                    // Dispatch logout event to the AuthBloc
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
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
