import 'package:flutter/material.dart';
import 'package:semo/core/presentation/widgets/bottom_sheets/reusable_bottom_sheet.dart';

void showStoreAddPeopleBottomSheet({
  required BuildContext context,
}) {
  showReusableBottomSheet(
    context: context,
    contentBuilder: (scrollController) => const StoreAddPeopleBottomSheet(),
    onClose: () => Navigator.of(context, rootNavigator: true).pop(),
  );
}

class StoreAddPeopleBottomSheet extends StatelessWidget {
  const StoreAddPeopleBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('Store Add People to be implemented'),
      ),
    );
  }
}
