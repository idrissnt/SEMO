import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:vibration/vibration.dart';

/// Widget that displays a product card
class ProductCard extends StatefulWidget {
  /// The product to display
  final CategoryProduct product;

  /// Creates a new product card
  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
              // add to cart button or quantity selector
              Positioned(
                top: 8,
                right: 8,
                child: _buildQuantityControl(),
              ),
            ],
          ),
        ),

        // Product details
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Product name
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // Price
              Text(
                '\$${widget.product.price.toStringAsFixed(2)} - ${widget.product.productUnit}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Product unit
              Text(
                '${widget.product.pricePerUnit.toStringAsFixed(2)}/${widget.product.unit}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the quantity control widget based on current quantity
  Widget _buildQuantityControl() {
    return quantity > 0
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus button
                _buildControlButton(
                  icon: Icons.remove,
                  onTap: () {
                    _vibrateButton();
                    setState(() {
                      if (quantity > 0) quantity--;
                    });
                  },
                ),
                // Quantity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Plus button
                _buildControlButton(
                  icon: Icons.add,
                  onTap: () {
                    _vibrateButton();
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
          )
        : _buildControlButton(
            icon: Icons.add,
            size: 20,
            isCircular: true,
            padding: 4,
            onTap: () {
              _vibrateButton();
              setState(() {
                quantity = 1;
              });
            },
          );
  }

  /// Builds a control button (plus or minus) with consistent styling
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 16,
    bool isCircular = false,
    double padding = 2,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: isCircular
            ? const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(icon, size: size, color: Colors.black),
      ),
    );
  }

  /// Provides haptic feedback when buttons are pressed
  void _vibrateButton() async {
    // Check if device supports vibration
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 20, amplitude: 80); // Short, light vibration
    }
  }
}
