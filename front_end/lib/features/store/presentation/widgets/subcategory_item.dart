import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/categories/store_category.dart';

/// Widget that displays a subcategory item
class SubcategoryItem extends StatelessWidget {
  /// The subcategory to display
  final StoreSubcategory subcategory;
  
  /// The index of this subcategory
  final int index;
  
  /// Whether this subcategory is selected
  final bool isSelected;
  
  /// Key for the selected subcategory
  final GlobalKey? itemKey;
  
  /// Callback when the subcategory is tapped
  final Function(int index) onTap;
  
  /// Creates a new subcategory item
  const SubcategoryItem({
    Key? key,
    required this.subcategory,
    required this.index,
    required this.isSelected,
    this.itemKey,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      key: itemKey,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Subcategory image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  subcategory.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Subcategory details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subcategory name
                    Text(
                      subcategory.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    // Subcategory description
                    if (subcategory.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subcategory.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Product count
                    const SizedBox(height: 8),
                    Text(
                      '${subcategory.products.length} products',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
