import 'package:flutter/material.dart';
import 'cart_painter.dart';

/// A widget that displays a shopping cart with transparent sections
/// allowing product images to appear as if they're inside the cart.
class TransparentCart extends StatelessWidget {
  /// The size of the cart
  final double size;

  /// The main dark color of the cart (outline, handle, frame)
  final Color outlineColor;

  /// The fill color of the cart's basket
  final Color basketColor;

  /// The opacity of the cart's basket (0.0 to 1.0)
  /// Lower values make the basket more transparent
  final double basketOpacity;

  /// The color of the cart's wheel centers
  final Color wheelCenterColor;

  /// Optional child widget to be displayed inside the cart
  final Widget? child;

  const TransparentCart({
    Key? key,
    required this.size,
    this.outlineColor = Colors.black, // Dark blue
    this.basketColor = Colors.white, // Light blue
    this.basketOpacity = 0.0,
    this.wheelCenterColor = const Color.fromARGB(255, 87, 92, 95), // Light blue
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The cart with transparent basket
          CustomPaint(
            painter: CartPainter(
              outlineColor: outlineColor,
              basketColor: basketColor,
              basketOpacity: basketOpacity,
              wheelCenterColor: wheelCenterColor,
            ),
            size: Size(size, size),
          ),

          // Optional child widget (could be product images)
          if (child != null) child!,
        ],
      ),
    );
  }
}
