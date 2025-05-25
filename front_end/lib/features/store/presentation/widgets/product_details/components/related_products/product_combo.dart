import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/widgets/product_details/utils/add_to_cart_button.dart';
import 'package:semo/features/store/presentation/widgets/products/product_card.dart';

/// Widget to display a "buy together" combo of 3 products
class ProductCombo extends StatelessWidget {
  final CategoryProduct mainProduct;
  final List<CategoryProduct> relatedProducts;
  final String storeId;

  const ProductCombo({
    Key? key,
    required this.mainProduct,
    required this.relatedProducts,
    required this.storeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if we have enough related products
    if (relatedProducts.length < 3) {
      return const SizedBox
          .shrink(); // Don't show this section if not enough products
    }

    // Calculate the total price of the 3 products
    final totalPrice = (mainProduct.price +
            relatedProducts[relatedProducts.length - 2].price +
            relatedProducts.last.price)
        .toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Le combo préféré de nos clients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Use Expanded with Flexible to ensure cards fit properly
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  // Use SizedBox to constrain width but allow height to adjust naturally
                  child: SizedBox(
                    width: double.infinity,
                    child: ProductCard(
                      product: relatedProducts.last,
                      relatedProducts: relatedProducts,
                      storeId: storeId,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: ProductCard(
                      product: mainProduct,
                      relatedProducts: relatedProducts,
                      storeId: storeId,
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ProductCard(
                      product: relatedProducts[relatedProducts.length - 2],
                      relatedProducts: relatedProducts,
                      storeId: storeId,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: AddToCartButton(
                text: "Ajouter les 3 articles",
                price: totalPrice,
                onPressed: () {
                  // Add to cart functionality
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
