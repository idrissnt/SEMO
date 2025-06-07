import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personnalisez vos préférences de livraison',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Définissez vos préférences pour une meilleure expérience de shopping',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            _buildPreferenceItem(
              icon: Icons.directions_car,
              title: 'Type de véhicule',
              subtitle: 'Choisissez votre moyen de transport préféré',
              type: 'vehicle',
              isVerified: _verificationStatus['vehicle'] ?? false,
            ),
            const Divider(),
            _buildPreferenceItem(
              icon: Icons.location_on,
              title: 'Zone de livraison',
              subtitle: 'Définissez votre zone de shopping',
              type: 'zone',
              isVerified: _verificationStatus['zone'] ?? false,
            ),
            const Divider(),
            _buildPreferenceItem(
              icon: Icons.store,
              title: 'Magasin préféré',
              subtitle: 'Sélectionnez votre magasin favori',
              type: 'store',
              isVerified: _verificationStatus['store'] ?? false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String type,
    required bool isVerified,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isVerified)
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Icon(Icons.edit, color: Colors.black),
              ],
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () => _navigateToPreferenceScreen(type),
    );
  }
}
