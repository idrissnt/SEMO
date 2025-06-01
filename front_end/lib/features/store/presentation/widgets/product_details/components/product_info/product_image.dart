import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/routes/bottom_sheet/product_detail/routes_constants.dart';

/// Widget to display the product image
class ProductImage extends StatelessWidget {
  final String imageUrl;

  const ProductImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Navigate to the image viewer screen
          context.pushNamed(
            BottomSheetProductDetailRoutesConstants.name,
            extra: {'imageUrl': imageUrl},
          );
        },
        child: Hero(
          tag: BottomSheetProductDetailRoutesConstants.heroTag,
          child: Image.network(
            imageUrl,
            height: 300,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
