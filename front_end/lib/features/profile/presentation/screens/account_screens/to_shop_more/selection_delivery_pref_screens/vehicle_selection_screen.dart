import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/button.dart';

class VehicleSelectionScreen extends StatefulWidget {
  const VehicleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  String? _selectedVehicle;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'bike',
      'name': 'Vélo / Scooter',
      'icon': const Icon(Icons.pedal_bike, color: Colors.blue),
    },
    {
      'id': 'car',
      'name': 'Voiture citadine / Vélo cargo',
      'icon': const Icon(Icons.directions_car, color: Colors.blue),
    },
    {
      'id': 'suv',
      'name': 'SUV',
      'icon': const Icon(Icons.directions_car_filled, color: Colors.orange),
    },
    {
      'id': 'van',
      'name': 'Camionnette',
      'icon': const Icon(Icons.airport_shuttle, color: Colors.green),
    },
  ];

  Future<void> _submitSelection() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner un type de véhicule')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to save vehicle preference
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préférence de véhicule enregistrée')),
      );
      context.pop(true); // Return true to indicate successful selection
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Type de véhicule'),
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
                    'Choisissez votre véhicule',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sélectionnez le type de véhicule que vous utilisez pour vos courses',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Vehicle options
                  ..._vehicles.map((vehicle) => _buildVehicleOption(vehicle)),

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

  Widget _buildVehicleOption(Map<String, dynamic> vehicle) {
    final bool isSelected = _selectedVehicle == vehicle['id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedVehicle = vehicle['id'];
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
              vehicle['icon'],
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  vehicle['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
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
