import 'package:flutter/material.dart';
import '../../../../data/models/store/product_model.dart';
import '../../../../core/theme/responsive_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadiusMedium),
      ),
      elevation: context.cardElevation,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              height: context.responsiveItemSize(120),
              width: double.infinity,
              child: Stack(
                children: [
                  // Product image
                  product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                        ),

                  // Add to cart button
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: context.xxs,
                            blurRadius: context.xs,
                            offset: Offset(0, context.xxs),
                          ),
                        ],
                      ),
                      child: IconButton(
                        constraints: BoxConstraints(
                          minWidth: context.m,
                          minHeight: context.m,
                        ),
                        iconSize: context.iconSizeSmall,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add),
                        onPressed: onAddToCart,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product information
            Padding(
              padding: EdgeInsets.all(context.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    '€${product.price.toStringAsFixed(2)}',
                    style: context.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.xxs),

                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium,
                  ),
                  SizedBox(height: context.xxs),

                  // Quantity
                  if (product.quantity.isNotEmpty &&
                      product.unit != null &&
                      product.unit!.isNotEmpty)
                    Text(
                      '${product.quantity} ${product.unit}',
                      style: context.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
