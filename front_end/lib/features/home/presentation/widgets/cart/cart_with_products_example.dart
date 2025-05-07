import 'package:flutter/material.dart';
import 'transparent_cart.dart';

/// An example widget that demonstrates how to use the TransparentCart
/// with product images positioned at various angles inside it.
class CartWithProductsExample extends StatelessWidget {
  final List<String> productImages;
  final double size;

  const CartWithProductsExample({
    Key? key,
    required this.productImages,
    this.size = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Product images positioned inside the cart at various angles
          if (productImages.isNotEmpty)
            Positioned(
              top: size * 0.3, // Position in the middle of the basket
              left: size * 0.3,
              child: Transform.rotate(
                angle: 0.2, // Slight tilt to the right
                child: _buildProductImage(
                    productImages[0], size * 0.2, size * 0.25),
              ),
            ),

          if (productImages.length > 1)
            Positioned(
              top: size * 0.35,
              left: size * 0.5,
              child: Transform.rotate(
                angle: -0.3, // Tilt to the left
                child: _buildProductImage(
                    productImages[1], size * 0.2, size * 0.25),
              ),
            ),

          if (productImages.length > 2)
            Positioned(
              top: size * 0.4,
              left: size * 0.35,
              child: Transform.rotate(
                angle: 0.1, // Very slight tilt to the right
                child: _buildProductImage(
                    productImages[2], size * 0.2, size * 0.25),
              ),
            ),

          // If there are more products, show a +N indicator
          if (productImages.length > 3)
            Positioned(
              top: size * 0.35,
              right: size * 0.25,
              child: Container(
                width: size * 0.15,
                height: size * 0.15,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '+${productImages.length - 3}',
                    style: TextStyle(
                      fontSize: size * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ),
            ),
          // The transparent cart
          TransparentCart(
            size: size,
            basketOpacity: 0.7, // Semi-transparent basket
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            spreadRadius: 0.5,
            offset: const Offset(0, 1),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
