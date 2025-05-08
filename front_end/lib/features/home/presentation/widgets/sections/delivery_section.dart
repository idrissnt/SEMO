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
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      width: sectionSize * 0.95,
      height: sectionSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8C6A8), // Lighter peach at top
            Color.fromARGB(255, 191, 88, 44), // Slightly darker peach at bottom
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(index),
          _builCartImageWithShadow(
              context, productsImagesList[index], cartImageSize),
          SizedBox(height: sectionSize * 0.05),
        ],
      ),
    );
  }

//
//
//
//
//

  _buildHeader(int index) {
    return SizedBox(
      width: sectionSize,
      height: sectionSize * 0.43,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: sectionSize * 0.25,
            child: Container(
              width: sectionSize * 0.4,
              height: sectionSize * 0.18,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    productsImagesList[index][5],
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: sectionSize * 0.15,
            left: sectionSize * 0.05,
            child: SizedBox(
              width: sectionSize * 0.8,
              height: sectionSize * 0.2,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: sectionSize * 0.3,
                      height: sectionSize * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "13${'€'}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: sectionSize * 0.3,
                      height: sectionSize * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '1.5 Km',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

//
//
//

  Widget _builCartImageWithShadow(
      BuildContext context, List<String> productImages, double cartImageSize) {
    return Column(
      children: [
        _buildCartImage(context, productImages, cartImageSize),
        const SizedBox(height: 3),
        Container(
          width: cartImageSize * 0.8,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 123, 42, 7),
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                    '+${productImages.length - 3}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ),
              ),
            ),
          // The transparent cart

          TransparentCart(
            size: cartImageSize,
            basketOpacity: 0.4, // Semi-transparent basket
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
