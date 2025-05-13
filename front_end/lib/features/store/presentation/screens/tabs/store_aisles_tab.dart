import 'package:flutter/material.dart';

/// Tab that displays the aisles content for a specific store
class StoreAislesTab extends StatelessWidget {
  /// The ID of the store
  final String storeId;
  
  const StoreAislesTab({
    Key? key, 
    required this.storeId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Mock aisles data for demonstration
    final aisles = [
      'Fresh Produce',
      'Dairy & Eggs',
      'Meat & Seafood',
      'Bakery',
      'Frozen Foods',
      'Pantry',
      'Snacks',
      'Beverages',
      'Household',
      'Personal Care',
      'Pet Supplies',
    ];
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: aisles.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            aisles[index],
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to aisle detail
          },
        );
      },
    );
  }
}
