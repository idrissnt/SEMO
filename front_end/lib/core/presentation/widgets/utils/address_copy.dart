import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyAddressToClipboard(BuildContext context, String address) {
  Clipboard.setData(ClipboardData(text: address)).then((_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adresse copiée: $address')),
    );
  });
}
