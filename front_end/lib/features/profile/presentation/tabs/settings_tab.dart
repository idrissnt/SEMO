import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';
import 'package:semo/core/presentation/widgets/offline_mode_toggle.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';

/// Tab for app settings and support
class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Support & About
          SettingsSection(
            title: 'Support & à propos',
            children: [
              SettingsTile(
                icon: AppIcons.star(size: 24, color: Colors.white),
                iconContainerColor: Colors.amber,
                title: 'Notez l\'application',
                subtitle: 'Dites-nous ce que vous pensez',
                onTap: () {},
              ),
              SettingsTile(
                icon: AppIcons.share(size: 24, color: Colors.white),
                iconContainerColor: Colors.orange,
                title: 'Partagez l\'application',
                subtitle: 'Invitez d\'autres à rejoindre',
                onTap: () {},
              ),
              SettingsTile(
                icon: AppIcons.help(size: 24, color: Colors.white),
                iconContainerColor: Colors.green,
                title: 'Aide',
                subtitle: 'FAQs, contactez-nous',
                onTap: () {},
              ),
              SettingsTile(
                icon: AppIcons.info(size: 24, color: Colors.white),
                iconContainerColor: Colors.blue,
                title: 'À propos',
                subtitle:
                    'Version de l\'app, termes, politique de confidentialité',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),
          // App Settings
          SettingsSection(
            title: 'Paramètres de l\'app',
            children: [
              SettingsTile(
                icon: AppIcons.notifications(size: 24, color: Colors.white),
                iconContainerColor: Colors.green,
                title: 'Notifications',
                subtitle:
                    'Notifications push, email, notifications dans l\'app',
                onTap: () {},
              ),
              SettingsTile(
                icon: AppIcons.privacy(size: 24, color: Colors.white),
                iconContainerColor: Colors.orange,
                title: 'Confidentialité',
                subtitle:
                    'Contrôlez vos données et vos paramètres de confidentialité',
                onTap: () {},
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const OfflineModeToggle(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // logout
          _buildAccountButton(context, 'Se deconnecter', false, () {
            // Close the dialog
            context.pop();
            // Dispatch logout event to the AuthBloc
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          }),
          const SizedBox(height: 16),

          // delete account
          _buildAccountButton(context, 'Supprimer mon compte', true, () {
            context.pop();
          }),
          const SizedBox(height: 24),

          // Version info
          _buildVersionInfo(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAccountButton(
    BuildContext context,
    String title,
    bool isDelete,
    Function onConfirm,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle logout

          showModalBottomSheet(
            backgroundColor: Colors.white,
            useRootNavigator: true,
            useSafeArea: true,
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isDelete ? 'Supprimer mon compte' : 'Se déconnecter',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Text(isDelete
                      ? 'Êtes-vous sûr de vouloir supprimer votre compte ?'
                      : 'Êtes-vous sûr de vouloir vous déconnecter ?'),
                  const SizedBox(height: 16),
                  ButtonFactory.createAnimatedButton(
                    context: context,
                    onPressed: () => onConfirm(),
                    text: isDelete ? 'Supprimer' : 'Se déconnecter',
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.textSecondaryColor,
                    splashColor: AppColors.primary,
                    highlightColor: AppColors.primary,
                    boxShadowColor: AppColors.primary,
                    minWidth: AppButtonDimensions.minWidth,
                    minHeight: AppButtonDimensions.minHeight,
                    verticalPadding: AppDimensionsWidth.xSmall,
                    horizontalPadding: AppDimensionsHeight.small,
                  ),
                  const SizedBox(height: 12),
                  ButtonFactory.createAnimatedButton(
                    context: context,
                    onPressed: () => context.pop(),
                    text: 'Annuler',
                    backgroundColor: AppColors.secondary,
                    textColor: AppColors.textPrimaryColor,
                    splashColor: AppColors.secondary,
                    highlightColor: AppColors.secondary,
                    boxShadowColor: AppColors.secondary,
                    minWidth: AppButtonDimensions.minWidth,
                    minHeight: AppButtonDimensions.minHeight,
                    verticalPadding: AppDimensionsWidth.xSmall,
                    horizontalPadding: AppDimensionsHeight.small,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isDelete ? 'Supprimer mon compte' : 'Se déconnecter',
          style: const TextStyle(
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
          const Text(
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
