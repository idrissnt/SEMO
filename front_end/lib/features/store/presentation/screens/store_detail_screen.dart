import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:semo/features/store/presentation/navigation/store_tab_controller.dart';
import 'package:semo/features/store/presentation/screens/components/store_detail_view.dart';

/// Screen that displays store details with bottom navigation
class StoreDetailScreen extends StatelessWidget {
  /// The ID of the store
  final String storeId;

  /// Initial tab index to display
  final int initialTab;

  /// Creates a new store detail screen
  const StoreDetailScreen({
    Key? key,
    required this.storeId,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the tab controller to the view
    return ChangeNotifierProvider(
      create: (_) => StoreTabController(initialTab: initialTab),
      child: StoreDetailView(storeId: storeId),
    );
  }
}
