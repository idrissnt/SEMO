import 'package:flutter/material.dart';
import 'package:semo/core/presentation/widgets/bottom_sheets/reusable_bottom_sheet.dart';

void showStoreInfoBottomSheet({
  required BuildContext context,
}) {
  showReusableBottomSheet(
    context: context,
    contentBuilder: (scrollController) => const StoreInfoBottomSheet(),
    onClose: () => Navigator.of(context, rootNavigator: true).pop(),
  );
}

class StoreInfoBottomSheet extends StatelessWidget {
  const StoreInfoBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('Store Info to be implemented'),
      ),
    );
  }
}
