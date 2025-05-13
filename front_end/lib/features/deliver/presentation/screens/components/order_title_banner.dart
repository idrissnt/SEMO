import 'package:flutter/material.dart';

/// A stylized banner that displays the order title with a gradient background
class OrderTitleBanner extends StatelessWidget {
  final String titleOne;

  const OrderTitleBanner({
    Key? key,
    required this.titleOne,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        titleOne,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}
