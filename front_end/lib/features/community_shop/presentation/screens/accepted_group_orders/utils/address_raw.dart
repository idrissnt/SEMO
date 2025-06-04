import 'package:flutter/material.dart';
import 'package:semo/core/presentation/widgets/utils/address_copy.dart';

Widget buildAddressRow(
  String address,
  BuildContext context,
) {
  return Row(
    children: [
      Expanded(
        child: Text(
          address,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      // Using a smaller widget than IconButton
      GestureDetector(
        onTap: () => copyAddressToClipboard(context, address),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: Icon(Icons.copy, size: 18),
        ),
      ),
    ],
  );
}
