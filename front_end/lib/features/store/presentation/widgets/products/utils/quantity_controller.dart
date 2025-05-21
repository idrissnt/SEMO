import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class ProductQuantityController extends StatefulWidget {
  final int initialQuantity;
  final double? width;
  final double? height;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final Function(int)? onQuantityChanged;

  const ProductQuantityController({
    Key? key,
    required this.initialQuantity,
    this.width = 120,
    this.height = 30,
    this.iconSize = 24,
    this.backgroundColor = Colors.white,
    this.iconColor,
    this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<ProductQuantityController> createState() =>
      _ProductQuantityControllerState();
}

class _ProductQuantityControllerState extends State<ProductQuantityController> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  /// Builds the quantity control widget based on current quantity
  @override
  Widget build(BuildContext context) {
    return quantity > 0
        ? Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Minus button
                _buildControlButton(
                  icon: Icons.remove,
                  iconColor: widget.iconColor,
                  onTap: () {
                    _vibrateButton();
                    setState(() {
                      if (quantity > 0) {
                        quantity--;
                        if (widget.onQuantityChanged != null) {
                          widget.onQuantityChanged!(quantity);
                        }
                      }
                    });
                  },
                ),
                // Quantity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: widget.iconColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Plus button
                _buildControlButton(
                  icon: Icons.add,
                  iconColor: widget.iconColor,
                  onTap: () {
                    _vibrateButton();
                    setState(() {
                      quantity++;
                      if (widget.onQuantityChanged != null) {
                        widget.onQuantityChanged!(quantity);
                      }
                    });
                  },
                ),
              ],
            ),
          )
        : _buildControlButton(
            icon: Icons.add,
            isCircular: true,
            iconColor: widget.iconColor,
            onTap: () {
              _vibrateButton();
              setState(() {
                quantity = 1;
                if (widget.onQuantityChanged != null) {
                  widget.onQuantityChanged!(quantity);
                }
              });
            },
          );
  }

  /// Builds a control button (plus or minus) with consistent styling
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isCircular = false,
    double padding = 2,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: isCircular
            ? BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
              )
            : null,
        child:
            Icon(icon, size: widget.iconSize, color: iconColor ?? Colors.black),
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
