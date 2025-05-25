import 'package:flutter/material.dart';

/// Widget for the top navigation bar with close and share buttons
class TopBar extends StatelessWidget {
  final VoidCallback onClose;
  final String? productName;
  final bool showProductName;

  const TopBar({
    Key? key,
    required this.onClose,
    this.productName,
    this.showProductName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: showProductName ? Colors.white : Colors.transparent,
        boxShadow: showProductName
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close, size: 20),
              ),
            ),
            onPressed: onClose,
          ),

          // Product name (shown when scrolled)
          if (showProductName && productName != null)
            Expanded(
              child: Text(
                productName!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Share button
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.share_outlined, size: 20),
              ),
            ),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
    );
  }
}
