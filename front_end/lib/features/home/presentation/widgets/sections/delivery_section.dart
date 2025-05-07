import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/home/presentation/widgets/cart/transparent_cart.dart';

/// An example widget that demonstrates how to use the TransparentCart
/// with product images positioned at various angles inside it.
class DeliverySection extends StatelessWidget {
  final List<List<String>> productsImagesList;
  final double sectionSize;

  const DeliverySection({
    Key? key,
    required this.productsImagesList,
    this.sectionSize = 180,
  }) : super(key: key);

  final double cartImageSize = 100;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: productsImagesList.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return _buildDeliverySection(context, index);
      },
    );
  }

  Widget _buildDeliverySection(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      width: sectionSize,
      height: sectionSize,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: sectionSize * 0.21,
                height: sectionSize * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      productsImagesList[index][0],
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: sectionSize * 0.2,
                child: Container(
                  width: sectionSize * 0.35,
                  height: sectionSize * 0.21,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "13${'€'}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: sectionSize * 0.2,
                child: Container(
                  width: sectionSize * 0.35,
                  height: sectionSize * 0.21,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '1.5 Km',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          _buildCartImage(context, productsImagesList[index], cartImageSize),
        ],
      ),
    );
  }

//
//
//
//
//
//
//
//
//
//
  Widget _buildCartImage(
      BuildContext context, List<String> productImages, double cartImageSize) {
    return SizedBox(
      width: cartImageSize,
      height: cartImageSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Product images positioned inside the cart at various angles
          if (productImages.length > 2)
            Positioned(
              top: cartImageSize * -0.1, // Position in the middle of the basket
              left: cartImageSize * 0.3,
              child: Transform.rotate(
                angle: 0.2, // Slight tilt to the right
                child: _buildProductImage(
                    productImages[0], cartImageSize * 0.3, cartImageSize * 0.4),
              ),
            ),

          if (productImages.length > 1)
            Positioned(
              top: cartImageSize * 0,
              left: cartImageSize * 0.55,
              child: Transform.rotate(
                angle: -0.3, // Tilt to the left
                child: _buildProductImage(
                    productImages[1], cartImageSize * 0.3, cartImageSize * 0.4),
              ),
            ),

          if (productImages.isNotEmpty)
            Positioned(
              top: cartImageSize * 0.25,
              left: cartImageSize * 0.35,
              child: Transform.rotate(
                angle: 0.1, // Very slight tilt to the right
                child: _buildProductImage(
                    productImages[2], cartImageSize * 0.4, cartImageSize * 0.4),
              ),
            ),

          // If there are more products, show a +N indicator
          if (productImages.length > 3)
            Positioned(
              top: cartImageSize * 0.01,
              right: cartImageSize * -0.25,
              child: Container(
                width: cartImageSize * 0.3,
                height: cartImageSize * 0.3,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
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
                    '+${productImages.length - 3}',
                    style: TextStyle(
                      fontSize: cartImageSize * 0.2,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ),
            ),
          // The transparent cart

          TransparentCart(
            size: cartImageSize,
            basketOpacity: 0.4, // Semi-transparent basket
          )
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
