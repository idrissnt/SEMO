import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget for the top navigation bar with close/back and share buttons
class TopBar extends StatelessWidget {
  final VoidCallback onClose;
  final String? productName;
  final bool showProductName;
  final bool isBackButton;
  final String? storeId;
  final String? productId;

  const TopBar({
    Key? key,
    required this.onClose,
    this.productName,
    this.showProductName = false,
    this.isBackButton = false,
    this.storeId,
    this.productId,
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
          // Close or back button
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(isBackButton ? Icons.arrow_back : Icons.close,
                    size: 20),
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
              // Create a shareable link if we have both storeId and productId
              if (storeId != null && productId != null) {
                final shareableLink =
                    'https://semo.win/store/$storeId/product/$productId';

                // Copy to clipboard
                Clipboard.setData(ClipboardData(text: shareableLink)).then((_) {
                  // Show a snackbar to confirm
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
