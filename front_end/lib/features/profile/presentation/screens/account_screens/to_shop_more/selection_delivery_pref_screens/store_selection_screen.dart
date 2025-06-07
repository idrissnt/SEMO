import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/presentation/screens/account_screens/utils/button.dart';

class StoreSelectionScreen extends StatefulWidget {
  const StoreSelectionScreen({Key? key}) : super(key: key);

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  String? _selectedStore;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _stores = [
    {
      'id': 'carrefour',
      'name': 'Carrefour',
      'logo': 'assets/images/carrefour_logo.png',
      'color': const Color(0xFF004E9F),
    },
    {
      'id': 'lidl',
      'name': 'Lidl',
      'logo': 'assets/images/lidl_logo.png',
      'color': const Color(0xFF0050AA),
    },
    {
      'id': 'leclerc',
      'name': 'E.Leclerc',
      'logo': 'assets/images/leclerc_logo.png',
      'color': const Color(0xFF0075BE),
    },
  ];

  Future<void> _submitSelection() async {
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un magasin')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call to save store preference
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Magasin préféré enregistré')),
      );
      context.pop(true); // Return true to indicate successful selection
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Magasin préféré'),
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
                    'Choisissez votre magasin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sélectionnez le magasin dans lequel vous préférez faire vos courses',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Store options
                  ..._stores.map((store) => _buildStoreOption(store)),
                  
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

  Widget _buildStoreOption(Map<String, dynamic> store) {
    final bool isSelected = _selectedStore == store['id'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStore = store['id'];
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
              // For actual implementation, use Image.asset with the logo path
              // Here we're using a placeholder since we don't have the actual assets
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: store['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    store['name'].substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  store['name'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
