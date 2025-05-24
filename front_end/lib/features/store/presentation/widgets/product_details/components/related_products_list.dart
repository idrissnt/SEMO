import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/widgets/products/product_card.dart';

/// Widget to display a horizontal list of related products
class RelatedProductsList extends StatelessWidget {
  final List<CategoryProduct> relatedProducts;
  final String storeId;
  
  const RelatedProductsList({
    Key? key,
    required this.relatedProducts,
    required this.storeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Souvent acheté avec',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // See all button
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text('Voir tout'),
                    Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedProducts.length,
            padding: const EdgeInsets.only(left: 16),
            itemBuilder: (context, index) {
              final product = relatedProducts[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: ProductCard(
                  product: product,
                  relatedProducts: relatedProducts,
                  storeId: storeId,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
