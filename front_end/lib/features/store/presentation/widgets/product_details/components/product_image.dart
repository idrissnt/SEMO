import 'package:flutter/material.dart';

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
      child: Image.network(
        imageUrl,
        height: 300,
        fit: BoxFit.cover,
      ),
    );
  }
}
