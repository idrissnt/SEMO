import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
import 'package:semo/features/profile/presentation/services/profile_interactions/account_interaction/delivery/delivery_preferences_interactions.dart';
import 'package:semo/features/profile/presentation/services/profile_interactions/account_interaction/personal_info/other_interactions.dart';
import 'package:semo/features/profile/presentation/services/profile_interactions/account_interaction/personal_info/account_verification_interactions.dart';

import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';

/// Tab for account-related settings
class AccountTab extends StatefulWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final PersonalInfoInteractionsService _personalInfoInteractionsService =
      PersonalInfoInteractionsService();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // personal info
          SettingsSection(
            title: 'Informations personnelles',
            children: [
              SettingsTile(
                isCompleted: false,
                title: 'Vérifier mon compte',
                subtitle: 'Piece d\'identité, email, numéro de téléphone',
                icon: AppIcons.person(size: 24, color: Colors.white),
                iconContainerColor: AppColors.primary,
                onTap: () {
                  AccountVerificationInteractionsService()
                      .handleAccountVerificationTap(context);
                },
              ),
              SettingsTile(
                title: 'Méthodes de paiement',
                subtitle: 'Cartes de crédit, comptes bancaires',
                icon: AppIcons.payment(size: 24, color: Colors.white),
                iconContainerColor: Colors.green,
                onTap: () {
                  _personalInfoInteractionsService
                      .handlePaymentMethodsTap(context);
                },
              ),
              SettingsTile(
                title: 'Adresses',
                subtitle: 'Ajouter une adresse',
                icon: AppIcons.location(size: 24, color: Colors.white),
                iconContainerColor: Colors.red,
                onTap: () {
                  _personalInfoInteractionsService.handleAddressTap(context);
                },
              ),
              SettingsTile(
                title: 'Sécurité',
                subtitle: 'Mot de passe',
                icon: AppIcons.security(size: 24, color: Colors.white),
                iconContainerColor: Colors.orange,
                onTap: () {
                  _personalInfoInteractionsService.handlePasswordTap(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // delivery time availability and preferences
          SettingsSection(
            title: 'Livraison ++',
            children: [
              SettingsTile(
                icon: AppIcons.calendar(size: 24, color: Colors.white),
                iconContainerColor: Colors.red,
                title: 'Mes disponibilités',
                subtitle: 'Quand allez-vous au magasin ?',
                onTap: () {},
              ),
              SettingsTile(
                icon: const Icon(Icons.route, size: 24, color: Colors.white),
                iconContainerColor: Colors.green,
                title: 'Mes trajets réguliers',
                subtitle: 'Pour des livraisons associées à vos trajets',
                onTap: () {},
              ),
              SettingsTile(
                icon: AppIcons.car(size: 24, color: Colors.white),
                iconContainerColor: Colors.orange,
                title: 'Préférences de livraison',
                subtitle: 'Véhicule, zones, magasins favoris',
                onTap: () {
                  DeliveryPreferencesInteractionsService()
                      .handleDeliveryPreferencesTap(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
