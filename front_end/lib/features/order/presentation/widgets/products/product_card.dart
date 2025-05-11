import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// A reusable product card widget for displaying product information
///
/// This widget is used in various places where products need to be displayed,
/// such as in popular products sections, search results, and store detail pages.
class ProductCard extends StatefulWidget {
  /// The name of the product
  final String name;

  /// The URL of the product image
  final String imageUrl;

  /// The price of the product
  final double productPrice;

  /// The unit of measurement (e.g., g, piece, pack)
  final String productUnit;

  /// The price per unit of the product
  final double pricePerUnit;

  /// The base unit of measurement (e.g., kg, piece, pack)
  final String baseUnit;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Callback when the add to cart button is pressed
  final VoidCallback onAddToCart;

  /// Width of the card, defaults to 140
  final double width;

  /// Height of the image section, defaults to 90
  final double imageHeight;

  const ProductCard({
    Key? key,
    required this.name,
    required this.productPrice,
    required this.productUnit,
    required this.imageUrl,
    required this.pricePerUnit,
    required this.baseUnit,
    required this.onTap,
    required this.onAddToCart,
    this.width = 140,
    this.imageHeight = 90,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // Track if product is in cart
  bool _isInCart = false;
  // Track product quantity
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            _buildProductImage(),
            // Product details
            _buildProductDetails(),
          ],
        ),
      ),
    );
  }

  /// Builds the product image section with error handling
  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        color: Colors.grey.shade200,
        height: widget.imageHeight,
        width: double.infinity,
        child: widget.imageUrl.isNotEmpty
            ? Image.network(
                widget.imageUrl,
                height: widget.imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                    ),
                  );
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  /// Builds a placeholder for when the image is not available
  Widget _buildImagePlaceholder() {
    return Container(
      height: widget.imageHeight,
      color: AppColors.surface,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  /// Builds the product details section with name, price, and add button
  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product name
          Text(
            textAlign: TextAlign.center,
            widget.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Product price and unit
          Text(
            textAlign: TextAlign.center,
            '${widget.productPrice.toStringAsFixed(2)}€ - ${widget.productUnit}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          // Product price per unit
          Text(
            textAlign: TextAlign.center,
            '${widget.pricePerUnit.toStringAsFixed(2)}€ / ${widget.baseUnit}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          // Add to cart button
          _buildAddToCartButton(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// Builds either the add to cart button or quantity control based on cart state
  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      height: 27,
      child: _isInCart
          ? _buildQuantityControl()
          : ElevatedButton(
              onPressed: () {
                setState(() {
                  _isInCart = true;
                });
                widget.onAddToCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ajouter au ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                  ),
                ],
              ),
            ),
    );
  }

  /// Builds the quantity control with minus, quantity display, and plus buttons
  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Minus button
          _buildControlButton(
            icon: Icons.remove,
            onPressed: () {
              if (_quantity > 1) {
                setState(() {
                  _quantity--;
                });
              } else {
                setState(() {
                  _isInCart = false;
                  _quantity = 1;
                });
              }
            },
          ),

          // Quantity display
          Text(
            textAlign: TextAlign.center,
            '$_quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          // Plus button
          _buildControlButton(
            icon: Icons.add,
            onPressed: () {
              setState(() {
                _quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Builds a control button (plus or minus) for the quantity control
  Widget _buildControlButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: icon == Icons.remove
              ? const BorderRadius.horizontal(left: Radius.circular(11))
              : const BorderRadius.horizontal(right: Radius.circular(11)),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
