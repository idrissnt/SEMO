import 'package:flutter/material.dart';
import 'package:semo/features/cart/domain/entities/cart.dart';
import 'package:semo/features/cart/presentation/widgets/animated_cart_bar.dart';

/// A scaffold that includes a cart bar at the bottom
class CartScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Cart cart;
  final VoidCallback onCartTap;
  final Function(String, int) onUpdateQuantity;
  final Function(String) onRemoveItem;
  final VoidCallback onViewCartPressed;

  const CartScaffold({
    Key? key,
    required this.body,
    required this.cart,
    required this.onCartTap,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onViewCartPressed,
    this.appBar,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          // Main content (takes full height)
          body,

          // Cart bar positioned at the bottom (only show if cart has items)
          if (!cart.isEmpty)
            Positioned(
              bottom: bottomNavigationBar != null
                  ? 90
                  : 30, // Adjust based on whether there's a bottom nav
              left: 0,
              right: 0,
              child: AnimatedCartBar(
                cart: cart,
                onCartTap: () => (),
              ),
              // child: CartBar(
              //   subtotal: cart.subtotal,
              //   deliveryFee: cart.deliveryFee,
              //   minimumOrderValue: cart.minimumOrderValue,
              //   progressToFreeDelivery: cart.progressToFreeDelivery,
              //   itemCount: cart.itemCount,
              //   onCartTap: () => (),
              // ),
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
