import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class ProductQuantityController extends StatefulWidget {
  final bool showRemoveButton;
  final int initialQuantity;
  final double? width;
  final double? height;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final Function(int)? onQuantityChanged;

  const ProductQuantityController({
    Key? key,
    this.showRemoveButton = false,
    required this.initialQuantity,
    this.width,
    this.height,
    this.iconSize = 24,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
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
            // Use constraints from parent if width/height are null
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(40),
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
              mainAxisSize: MainAxisSize.min, // Take minimum space needed
              children: [
                // Minus button
                _buildControlButton(
                  icon: quantity == 1 ? Icons.delete : Icons.remove,
                  // Gray out the button if it's disabled (quantity=1 in BottomBar)
                  iconColor: _isMinusButtonDisabled()
                      ? widget.iconColor?.withValues(alpha: 0.5)
                      : widget.iconColor,
                  // Disable the button if quantity=1 in BottomBar
                  onTap: _isMinusButtonDisabled()
                      ? null
                      : () {
                          _vibrateButton();
                          _handleDecrement();
                        },
                ),
                // Quantity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
    VoidCallback? onTap,
    bool isCircular = false,
    double padding = 2,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      // Disable the ripple effect when onTap is null
      splashColor: onTap == null ? Colors.transparent : null,
      highlightColor: onTap == null ? Colors.transparent : null,
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

  /// Determines if the minus/delete button should be disabled
  bool _isMinusButtonDisabled() {
    return quantity == 1 && widget.showRemoveButton;
  }

  /// Handles the decrement/delete action based on current quantity and settings
  void _handleDecrement() {
    setState(() {
      if (quantity == 1 && !widget.showRemoveButton) {
        // Delete the item when quantity is 1 and we're not in BottomBar
        quantity = 0;
      } else if (quantity > 1) {
        // Just decrement if quantity is greater than 1
        quantity--;
      }

      // Notify about the change
      if (widget.onQuantityChanged != null) {
        widget.onQuantityChanged!(quantity);
      }
    });
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
