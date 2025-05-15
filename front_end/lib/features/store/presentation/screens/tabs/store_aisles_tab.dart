import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/test_data/store_aisles_data.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// Tab that displays the aisles content for a specific store
class StoreAislesTab extends StatefulWidget {
  /// The ID of the store
  final String storeId;

  const StoreAislesTab({
    Key? key,
    required this.storeId,
  }) : super(key: key);

  @override
  State<StoreAislesTab> createState() => _StoreAislesTabState();
}

class _StoreAislesTabState extends State<StoreAislesTab>
    with AutomaticKeepAliveClientMixin {
  /// Categories data
  List<StoreAisle> _aisles = [];

  /// Loading state
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAisles();
  }

  /// Loads the aisles data
  Future<void> _loadAisles() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Get aisles from mock data
    final aisles = StoreAisleData.getMockAisles();

    if (mounted) {
      setState(() {
        _aisles = aisles;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildListWithPaddedSeparators(
      items: _aisles,
      itemBuilder: (aisle) => _buildAisleItem(aisle),
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  /// Helper function to build a list with padded separators, including one at the end
  Widget _buildListWithPaddedSeparators<T>({
    required List<T> items,
    required Widget Function(T item) itemBuilder,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      padding: padding,
      itemCount: items.length + 1, // +1 for the final separator
      itemBuilder: (context, index) {
        // If it's the last index, show only the final separator
        if (index == items.length) {
          return _buildPaddedSeparator();
        }

        final item = itemBuilder(items[index]);

        // Add a separator after each item except the last one
        if (index < items.length - 1) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [item, _buildPaddedSeparator()],
          );
        }

        return item;
      },
    );
  }

  /// Helper function to build a padded separator
  Widget _buildPaddedSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
    );
  }

  /// Builds a simple aisle item with a small image on the left
  Widget _buildAisleItem(StoreAisle aisle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          aisle.imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 56,
            height: 56,
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 24),
          ),
        ),
      ),
      title: Text(
        aisle.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Navigate to aisle detail
        context.go(StoreRoutesConst.getStoreProductForAisleRoute(
          widget.storeId,
          aisle.id,
        ));
      },
    );
  }
}
