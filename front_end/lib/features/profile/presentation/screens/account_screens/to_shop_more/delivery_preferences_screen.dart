import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/section_list.dart';
import 'package:semo/features/profile/presentation/services/profile_interactions/account_interaction/delivery/delivery_preferences_interactions.dart';

class DeliveryPreferencesScreen extends StatefulWidget {
  const DeliveryPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryPreferencesScreen> createState() =>
      _DeliveryPreferencesScreenState();
}

class _DeliveryPreferencesScreenState extends State<DeliveryPreferencesScreen> {
  final Map<String, bool> _verificationStatus = {
    'vehicle': false,
    'zone': false,
    'store': false,
  };

  final DeliveryPreferencesInteractionsService _preferencesInteractions =
      DeliveryPreferencesInteractionsService();

  Future<void> _navigateToPreferenceScreen(String type) async {
    bool isSelected = false;

    switch (type) {
      case 'vehicle':
        isSelected =
            await _preferencesInteractions.handleVehicleSelectionTap(context);
        break;
      case 'zone':
        isSelected =
            await _preferencesInteractions.handleZoneSelectionTap(context);
        break;
      case 'store':
        isSelected =
            await _preferencesInteractions.handleStoreSelectionTap(context);
        break;
    }

    if (isSelected && mounted) {
      setState(() {
        _verificationStatus[type] = isSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Préférences de livraison'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Personnalisez vos préférences de livraison',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Définissez vos préférences pour une meilleure expérience de shopping',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildSection([
              buildListItem(
                title: 'Type de véhicule',
                icon: Icons.directions_car,
                isVerified: _verificationStatus['vehicle'] ?? false,
                onTap: () => _navigateToPreferenceScreen('vehicle'),
                iconColor: Colors.orange,
              ),
              buildListItem(
                title: 'Zone de livraison',
                icon: Icons.location_on,
                isVerified: _verificationStatus['zone'] ?? false,
                onTap: () => _navigateToPreferenceScreen('zone'),
                iconColor: Colors.red,
              ),
              buildListItem(
                title: 'Magasin préféré',
                icon: Icons.store,
                isVerified: _verificationStatus['store'] ?? false,
                onTap: () => _navigateToPreferenceScreen('store'),
                iconColor: Colors.green,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
