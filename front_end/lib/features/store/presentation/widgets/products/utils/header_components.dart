import 'package:flutter/material.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Build the drag handle at the top of the sheet
Widget buildDragHandle() {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    height: 4,
    width: 40,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

/// Build the header with product name and close button
Widget buildHeader({
  required CategoryProduct product,
  required BuildContext context,
  required bool isNestedProduct,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(
            product.name.length > 25
                ? '${product.name.substring(0, 25)}...'
                : product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Close button with additional functionality for nested sheets
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // If we're in a nested sheet, show a dialog asking if the user wants to close all or just this one
            if (isNestedProduct) {
              _showCloseOptionsDialog(context);
            } else {
              // Just close this sheet
              Navigator.pop(context);
            }
          },
        ),
      ],
    ),
  );
}

/// Show dialog with options to close current sheet or all sheets
void _showCloseOptionsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Close options'),
      content: const Text('You have multiple product sheets open.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close current sheet
          },
          child: const Text('Close this one'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            // Close all sheets
            _closeAllSheets(context);
          },
          child: const Text('Close all'),
        ),
      ],
    ),
  );
}

/// Close all bottom sheets
void _closeAllSheets(BuildContext context) {
  Navigator.of(context).popUntil((route) {
    return route.isFirst || !(route is ModalBottomSheetRoute);
  });
}
