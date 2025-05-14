import 'package:flutter/material.dart';
import 'package:semo/features/cart/domain/entities/cart.dart';
import 'package:semo/features/cart/presentation/widgets/animated_cart_bar.dart';
import 'package:semo/features/cart/presentation/widgets/cart_bottom_sheet.dart';

/// A scaffold that includes a cart bar at the bottom
class CartScaffold extends StatelessWidget {
  /// The main content of the scaffold
  final Widget body;

  /// The app bar to display at the top
  final PreferredSizeWidget? appBar;

  /// Bottom navigation bar to display below the cart bar
  final Widget? bottomNavigationBar;

  /// The cart data
  final Cart cart;

  /// Callback when the cart bar is tapped
  final VoidCallback onCartTap;

  /// Callback to update item quantity
  final Function(String, int) onUpdateQuantity;

  /// Callback to remove an item
  final Function(String) onRemoveItem;

  /// Callback when view cart is pressed in the bottom sheet
  final VoidCallback onViewCartPressed;

  /// Callback when checkout is pressed
  final VoidCallback onCheckoutPressed;

  const CartScaffold({
    Key? key,
    required this.body,
    required this.cart,
    required this.onCartTap,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onViewCartPressed,
    required this.onCheckoutPressed,
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
                onCartTap: () => _showCartBottomSheet(context),
              ),
              // child: CartBar(
              //   subtotal: cart.subtotal,
              //   deliveryFee: cart.deliveryFee,
              //   minimumOrderValue: cart.minimumOrderValue,
              //   progressToFreeDelivery: cart.progressToFreeDelivery,
              //   itemCount: cart.itemCount,
              //   onCartTap: () => _showCartBottomSheet(context),
              // ),
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(
        cart: cart,
        onUpdateQuantity: onUpdateQuantity,
        onRemoveItem: onRemoveItem,
        onViewCartPressed: () {
          Navigator.of(context).pop();
          onViewCartPressed();
        },
        onCheckoutPressed: () {
          Navigator.of(context).pop();
          onCheckoutPressed();
        },
      ),
    );
  }
}
