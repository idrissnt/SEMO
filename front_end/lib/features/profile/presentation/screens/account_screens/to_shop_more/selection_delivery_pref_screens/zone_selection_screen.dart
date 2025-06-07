import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/button.dart';

class ZoneSelectionScreen extends StatefulWidget {
  const ZoneSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ZoneSelectionScreen> createState() => _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends State<ZoneSelectionScreen> {
  String? _selectedZoneType;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cityController.dispose();
    _zipCodeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _submitSelection() async {
    if (_selectedZoneType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un type de zone')),
      );
      return;
    }

    // Validate input based on zone type
    if (_selectedZoneType == 'city' && _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le nom de la ville')),
      );
      return;
    }

    if (_selectedZoneType == 'zipCode' && _zipCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un code postal')),
      );
      return;
    }

    if (_selectedZoneType == 'radius' && _radiusController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un rayon')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to save zone preference
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zone de livraison enregistrée')),
      );
      context.pop(true); // Return true to indicate successful selection
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Zone de livraison'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Définissez votre zone',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choisissez la zone dans laquelle vous souhaitez faire vos courses',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Zone type options
                  _buildZoneOption(
                    title: 'Par ville',
                    subtitle: 'Sélectionnez une ville spécifique',
                    value: 'city',
                    icon: Icons.location_city,
                  ),
                  
                  if (_selectedZoneType == 'city')
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 16.0),
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de la ville',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  
                  _buildZoneOption(
                    title: 'Par code postal',
                    subtitle: 'Sélectionnez un code postal spécifique',
                    value: 'zipCode',
                    icon: Icons.markunread_mailbox,
                  ),
                  
                  if (_selectedZoneType == 'zipCode')
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 16.0),
                      child: TextFormField(
                        controller: _zipCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Code postal',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  
                  _buildZoneOption(
                    title: 'Par rayon',
                    subtitle: 'Définissez un rayon autour de votre adresse',
                    value: 'radius',
                    icon: Icons.radio_button_checked,
                  ),
                  
                  if (_selectedZoneType == 'radius')
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _radiusController,
                              decoration: const InputDecoration(
                                labelText: 'Rayon (km)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('km', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit button
                  Center(
                    child: createVerificationButton(
                      context: context,
                      onPressed: _submitSelection,
                      text: 'Confirmer',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildZoneOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final bool isSelected = _selectedZoneType == value;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedZoneType = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
            color: isSelected ? Colors.blue.shade50 : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
