import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeliverySection extends StatelessWidget {
  const DeliverySection({
    required this.productsImages,
    Key? key,
  }) : super(key: key);

  final List<String> productsImages;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Big shopping cart icon
        Container(
          margin: const EdgeInsets.only(left: 16),
          padding: const EdgeInsets.all(0),
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _actionIconButton(
            icon: CupertinoIcons.cart_fill,
            color: Colors.white,
            onPressed: () {
              // Handle cart tap
            },
            size: 120,
          ),
        ),
        // Product images stacked on top of the cart icon
        if (productsImages.isNotEmpty)
          Positioned(
            top: 25,
            right: 65,
            child: Container(
              padding: const EdgeInsets.all(0),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(productsImages[0]),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        if (productsImages.length > 1)
          Positioned(
            top: -5,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(0),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(productsImages[1]),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        if (productsImages.length > 2)
          Positioned(
            top: 8,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(0),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(productsImages[2]),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        // If there are more than 3 products, show a +N indicator
        if (productsImages.length > 3)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(0),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '+${productsImages.length - 3}',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
      constraints: const BoxConstraints(),
      iconSize: size,
      visualDensity: const VisualDensity(horizontal: -2, vertical: 0),
    );
  }
}
