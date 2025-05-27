import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/components/order_card_footer.dart';

class ProductCarousel extends StatefulWidget {
  final CommunityOrder order;

  const ProductCarousel({Key? key, required this.order}) : super(key: key);

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  // Initialize with the second image index if available
  late int _currentIndex;  
  
  @override
  void initState() {
    super.initState();
    // Set initial index to match initialPage in CarouselOptions
    _currentIndex = widget.order.productImageUrls.length > 1 ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Produits commandés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const Spacer(),
            OrderCardFooter(
              order: widget.order,
            ).buildReward()
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                initialPage: widget.order.productImageUrls.length > 1 ? 1 : 0,
                height: 220,
                viewportFraction: 0.85,
                enlargeCenterPage: true,
                enableInfiniteScroll: false, // Disable infinite scrolling
                enlargeStrategy: CenterPageEnlargeStrategy.height,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: widget.order.productImageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Product Image
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.error)),
                                );
                              },
                            ),
                          ),

                          // Favorite button
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'x 1',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            // Page indicator dots
            if (widget.order.productImageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.order.productImageUrls
                      .asMap()
                      .entries
                      .map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? AppColors.primary
                            : Colors.grey.shade400,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
