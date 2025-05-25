import 'package:flutter/material.dart';
import 'package:semo/features/store/presentation/widgets/product_details/utils/add_to_cart_button.dart';
import 'package:semo/features/store/presentation/widgets/products/utils/quantity_controller.dart';

/// Widget for the bottom bar with quantity controller and add to cart button
class BottomBar extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onAddToCart;
  final String productPrice;

  const BottomBar({
    Key? key,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.productPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity controller
          SizedBox(
            width: 110,
            height: 50,
            child: ProductQuantityController(
              showRemoveButton: true,
              initialQuantity: quantity,
              onQuantityChanged: onQuantityChanged,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 12),
          // Add to cart button
          Expanded(
            child: AddToCartButton(
              icon: Icons.add_shopping_cart,
              text: 'Ajouter au  ',
              price: productPrice,
              onPressed: onAddToCart,
            ),
          ),
        ],
      ),
    );
  }
}
