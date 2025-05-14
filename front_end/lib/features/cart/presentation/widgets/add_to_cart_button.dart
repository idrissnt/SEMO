import 'package:flutter/material.dart';

class AddToCartButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isInCart;
  final int quantity;
  final Function(int)? onQuantityChanged;

  const AddToCartButton({
    Key? key,
    required this.onPressed,
    this.isInCart = false,
    this.quantity = 0,
    this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isInCart && quantity > 0) {
      return _buildQuantityControls();
    } else {
      return _buildAddButton();
    }
  }

  Widget _buildAddButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          _buildControlButton(
            icon: Icons.remove,
            onTap: () {
              if (onQuantityChanged != null) {
                onQuantityChanged!(quantity - 1);
              }
            },
          ),
          
          // Quantity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          // Increase button
          _buildControlButton(
            icon: Icons.add,
            onTap: () {
              if (onQuantityChanged != null) {
                onQuantityChanged!(quantity + 1);
              }
            },
            color: Colors.green,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color iconColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 16,
        ),
      ),
    );
  }
}
