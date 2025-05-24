import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/widgets/product_details/components/expandable_section.dart';

/// Widget to display the product information section
class ProductInfo extends StatelessWidget {
  final CategoryProduct product;
  
  const ProductInfo({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Product price per unit
          Text(
            '${product.pricePerUnit.toStringAsFixed(2)}/${product.unit}',
            style: const TextStyle(
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Product price and unit
          const SizedBox(height: 8),
          Text(
            '${product.price.toStringAsFixed(2)}€ - ${product.productUnit}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Expandable ingredients button
          if (product.ingredient != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ExpandableSection(
                  title: 'Ingredients',
                  content: product.ingredient!,
                ),
                // Uncomment if you want to add nutrition info
                // ExpandableSection(
                //   title: 'Nutrition',
                //   content: 'Nutrition information will be displayed here.',
                // ),
              ],
            ),
        ],
      ),
    );
  }
}
