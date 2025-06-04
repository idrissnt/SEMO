import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/initial_screen/utils/models.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/search_bar_widget.dart';

/// Screen for adding a new product to the order
class AddItemScreen extends StatefulWidget {
  final CommunityOrder order;

  const AddItemScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final AppLogger _logger = AppLogger();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _aisleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _aisleController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _addManualItem() {
    // Validate inputs
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom de produit')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;

    // Create a new item with manually entered details
    final newItem = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      imageUrl: '', // Default placeholder image
      quantity: quantity,
      unit: _unitController.text.isEmpty ? 'unité' : _unitController.text,
      valueUnit: 1.0, // Default value
      price: price,
      position: 'À déterminer', // Default position
      aisle: _aisleController.text.isEmpty ? 'Autre' : _aisleController.text,
      status: OrderItemStatus.inProgress,
    );

    _logger.info('Manual product added: ${newItem.name}');
    // Close the bottom sheet and return the new item
    Navigator.pop(context, newItem);
  }

  void _showManualEntryBottomSheet() async {
    // Clear form fields before showing the bottom sheet
    _nameController.clear();
    _quantityController.clear();
    _unitController.clear();
    _priceController.clear();
    _aisleController.clear();

    final OrderItem? result = await showModalBottomSheet<OrderItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 8,
          left: 8,
          right: 8,
        ),
        child: _buildManualEntryForm(),
      ),
    );

    // If an item was added, return it to the previous screen
    if (result != null) {
      _logger.info('Returning manually added item: ${result.name}');
      if (mounted) {
        context.pop(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Ajouter un produit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildSearchScreen(),
    );
  }

  Widget _buildSearchScreen() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: SearchBarWidget(
            isScrolled: false,
            hintText: 'Rechercher un produit...',
            searchController: _searchController,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            _showManualEntryBottomSheet();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ajouter un produit manuellement',
                style: TextStyle(color: AppColors.primary, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Container(
                height: 24,
                width: 24,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ajouter un produit manuellement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Name field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nom du produit *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Quantity and Unit in a row
          Row(
            children: [
              // Quantity field
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              // Unit field
              Expanded(
                child: TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unité',
                    hintText: 'ex: kg, unité',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price field
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Prix (€)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 32),

          // Add button
          ElevatedButton(
            onPressed: _addManualItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Ajouter le produit',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
