import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/widgets/cart/transparent_cart.dart';

/// Widget that displays product images in a shopping cart
class ProductImagesDisplay extends StatelessWidget {
  final List<String> productImageUrls;
  final double width;
  final double height;

  const ProductImagesDisplay({
    Key? key,
    required this.productImageUrls,
    this.width = 120,
    this.height = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          if (productImageUrls.length > 1)
            Positioned(
              top: 0,
              left: 30,
              child: Transform.rotate(
                angle: 0.2, // Slight tilt to the right
                child: _buildProductImage(productImageUrls[0], 50, 70),
              ),
            ),
          if (productImageUrls.isNotEmpty)
            Positioned(
              top: 5,
              left: 45,
              child: Transform.rotate(
                angle: -0.3, // Tilt to the left
                child: _buildProductImage(
                    productImageUrls.length > 1
                        ? productImageUrls[1]
                        : productImageUrls[0],
                    50,
                    70),
              ),
            ),
          // If there are more products, show a +N indicator
          if (productImageUrls.length > 2)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.storeCardBorderColor,
                    width: 1.5,
                  ),
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
                    '+${productImageUrls.length - 2}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ),
              ),
            ),
          const TransparentCart(
            size: 120,
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
            color: Colors.black.withValues(alpha: 0.5),
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
