import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/utils/models.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

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
  
  // Sample products for search results
  List<OrderItem> _allProducts = [];
  List<OrderItem> _filteredProducts = [];
  bool _isManualEntry = false;

  @override
  void initState() {
    super.initState();
    // Initialize with sample products
    _allProducts = OrderItem.getSampleItems();
    _filteredProducts = List.from(_allProducts);
  }

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

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = List.from(_allProducts);
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(lowercaseQuery) ||
            product.aisle.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  void _selectProduct(OrderItem product) {
    _logger.info('Product selected: ${product.name}');
    
    // Create a new item with status set to inProgress
    final newItem = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
      name: product.name,
      imageUrl: product.imageUrl,
      quantity: 1, // Default quantity
      unit: product.unit,
      valueUnit: product.valueUnit,
      price: product.price,
      position: product.position,
      aisle: product.aisle,
      status: OrderItemStatus.inProgress,
    );
    
    // Return the new item to the previous screen
    context.pop(newItem);
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
    final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
    
    // Create a new item with manually entered details
    final newItem = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      imageUrl: 'https://via.placeholder.com/150', // Default placeholder image
      quantity: quantity,
      unit: _unitController.text.isEmpty ? 'unité' : _unitController.text,
      valueUnit: 1.0, // Default value
      price: price,
      position: 'À déterminer', // Default position
      aisle: _aisleController.text.isEmpty ? 'Autre' : _aisleController.text,
      status: OrderItemStatus.inProgress,
    );
    
    _logger.info('Manual product added: ${newItem.name}');
    context.pop(newItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isManualEntry)
            TextButton(
              onPressed: () {
                setState(() {
                  _isManualEntry = true;
                });
              },
              child: const Text(
                'Saisie manuelle',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isManualEntry ? _buildManualEntryForm() : _buildSearchScreen(),
    );
  }

  Widget _buildSearchScreen() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _filterProducts('');
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: _filterProducts,
          ),
        ),
        
        // Results
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun produit trouvé',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(OrderItem product) {
    return GestureDetector(
      onTap: () => _selectProduct(product),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Add button overlay
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    product.aisle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          const SizedBox(height: 16),
          
          // Aisle field
          TextField(
            controller: _aisleController,
            decoration: const InputDecoration(
              labelText: 'Rayon',
              hintText: 'ex: Fruits et légumes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          
          // Add button
          ElevatedButton(
            onPressed: _addManualItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Ajouter le produit',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cancel button
          TextButton(
            onPressed: () {
              setState(() {
                _isManualEntry = false;
              });
            },
            child: const Text('Revenir à la recherche'),
          ),
        ],
      ),
    );
  }
}
