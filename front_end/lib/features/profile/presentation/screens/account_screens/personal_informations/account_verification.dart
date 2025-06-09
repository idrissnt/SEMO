import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/widgets/buttons/back_button.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/section_list.dart';
import 'package:semo/features/profile/presentation/services/profile_interactions/account_interaction/personal_info/account_verification_interactions.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({Key? key}) : super(key: key);

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  // Track verification status for each item
  final Map<String, bool> _verificationStatus = {
    'name': false,
    'email': false,
    'phone': false,
    'id_card': false,
  };

  final AccountVerificationInteractionsService _verificationInteractions =
      AccountVerificationInteractionsService();

  Future<void> _navigateToVerificationScreen(String type) async {
    bool? isVerified;

    switch (type) {
      case 'name':
        isVerified =
            await _verificationInteractions.handleNameVerificationTap(context);
        break;
      case 'email':
        isVerified =
            await _verificationInteractions.handleEmailVerificationTap(context);
        break;
      case 'phone':
        isVerified =
            await _verificationInteractions.handlePhoneVerificationTap(context);
        break;
      case 'id_card':
        isVerified = await _verificationInteractions
            .handleIdCardVerificationTap(context);
        break;
    }

    if (isVerified == true) {
      setState(() {
        _verificationStatus[type] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS settings background color
      appBar: AppBar(
        title: const Text('Vérifier mon compte'),
        leading: IconButton(
          icon: buildIconButton(Icons.arrow_back, Colors.black, Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 35),

          // First section
          buildSection([
            buildListItem(
              title: 'Nom complet',
              icon: Icons.person,
              isVerified: _verificationStatus['name'] ?? false,
              onTap: () => _navigateToVerificationScreen('name'),
              iconColor: Colors.green,
            ),
            buildListItem(
              title: 'Adresse email',
              icon: Icons.email,
              isVerified: _verificationStatus['email'] ?? false,
              onTap: () => _navigateToVerificationScreen('email'),
              iconColor: Colors.blue,
            ),
          ]),

          const SizedBox(height: 35),

          // Second section
          buildSection([
            buildListItem(
              title: 'Numéro de téléphone',
              icon: Icons.phone,
              isVerified: _verificationStatus['phone'] ?? false,
              onTap: () => _navigateToVerificationScreen('phone'),
              iconColor: Colors.green,
            ),
            buildListItem(
              title: 'Pièce d\'identité',
              icon: Icons.badge,
              isVerified: _verificationStatus['id_card'] ?? false,
              onTap: () => _navigateToVerificationScreen('id_card'),
              iconColor: Colors.blue,
            ),
          ]),
        ],
      ),
    );
  }
}
