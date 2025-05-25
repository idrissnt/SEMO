import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/bottom_sheet_nav/bottom_sheet_navigator.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/widgets/product_details/product_detail.dart';
import 'package:semo/features/store/routes/bottom_sheet/product_detail/routes_constants.dart';
import 'utils/quantity_controller.dart';

/// Widget that displays a product card
class ProductCard extends StatefulWidget {
  /// The product to display
  final CategoryProduct product;

  /// The related products
  final List<CategoryProduct>? relatedProducts;

  /// The store ID
  final String storeId;

  /// Creates a new product card
  const ProductCard({
    Key? key,
    required this.product,
    required this.relatedProducts,
    required this.storeId,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Product image
              InkWell(
                onTap: () {
                  // Check if we're inside a product detail navigator
                  final navigatorState = context
                      .findAncestorStateOfType<BottomSheetNavigatorState>();

                  if (navigatorState != null) {
                    // We're inside a bottom sheet navigator, navigate to the related product
                    navigatorState.navigateTo(
                      ProductDetailRoutesConstants.relatedProduct
                          .replaceAll(':productId', widget.product.id),
                    );
                  } else {
                    // We're not in a navigator, show the bottom sheet
                    showProductDetailBottomSheet(
                        context: context,
                        product: widget.product,
                        storeId: widget.storeId,
                        relatedProducts: widget.relatedProducts!);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    ),
                  ),
                ),
              ),
              // add to cart button or quantity selector
              Positioned(
                top: 8,
                right: 8,
                left: quantity > 0 ? 8 : null,
                child: ProductQuantityController(
                  initialQuantity: quantity,
                  // Let the controller use the constraints from Positioned
                  // No fixed width or height
                  backgroundColor: Colors.white,
                  iconColor: Colors.black,
                  // Update quantity in the state
                  onQuantityChanged: (newQuantity) {
                    setState(() {
                      quantity = newQuantity;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Product details
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Product name
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // Price and unit
              Text(
                '\$${widget.product.price.toStringAsFixed(2)} - ${widget.product.productUnit}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Product price per unit
              Text(
                '${widget.product.pricePerUnit.toStringAsFixed(2)}/${widget.product.unit}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
