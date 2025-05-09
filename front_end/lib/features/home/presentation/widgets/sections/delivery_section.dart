import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/home/presentation/widgets/cart/transparent_cart.dart';

/// An example widget that demonstrates how to use the TransparentCart
/// with product images positioned at various angles inside it.
class DeliverySection extends StatelessWidget {
  final String title;
  final List<List<String>> productsImagesList;
  final double sectionSize;

  const DeliverySection({
    Key? key,
    required this.title,
    required this.productsImagesList,
    this.sectionSize = 180,
  }) : super(key: key);

  final double cartImageSize = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              itemCount: productsImagesList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return _buildDeliverySection(context, index);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionTitle(String sectionTitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            child: Text(
              textAlign: TextAlign.start,
              maxLines: 2,
              sectionTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: TextButton(
            onPressed: () {
              // Navigate to all delivery available
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(30, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliverySection(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      width: sectionSize,
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
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
          // SizedBox(height: sectionSize * 0.05),
          _buildDoButton(sectionSize),
        ],
      ),
    );
  }

//
//
//
//
//

  Widget _buildHeader(int index) {
    return SizedBox(
      width: sectionSize,
      height: sectionSize * 0.32,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 50,
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
            top: 0,
            left: 5,
            child: SizedBox(
              width: sectionSize * 0.9,
              height: sectionSize * 0.32,
              child: Stack(
                children: [
                  Positioned(
                    top: 7,
                    right: 0,
                    child: Transform.rotate(
                      angle: 20 * 0.0174533,
                      child: Container(
                        width: sectionSize * 0.33,
                        height: sectionSize * 0.22,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                          shape: BoxShape.rectangle,
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '12 €  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'pour vous',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    left: 0,
                    child: Transform.rotate(
                      angle: -20 * 0.0174533,
                      child: Container(
                        width: sectionSize * 0.33,
                        height: sectionSize * 0.22,
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                          shape: BoxShape.rectangle,
                          color: const Color.fromARGB(255, 191, 88, 44),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '1.5 Km ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'de vous',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
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
            basketOpacity: 0.0, // Semi-transparent basket
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

  Widget _buildDoButton(double sectionSize) {
    return SizedBox(
      height: sectionSize * 0.17,
      width: sectionSize * 0.9,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.black,
          elevation: 12,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          // minimumSize: const Size(double.infinity, 30),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          textAlign: TextAlign.center,
          'Je m\'en occupe',
          maxLines: 1,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
