import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/categories/store_category.dart';
import 'package:semo/features/store/presentation/test_data/store_categories_data.dart';
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
  List<StoreCategory> _categories = [];

  /// Loading state
  bool _isLoading = true;



  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Loads the categories data
  Future<void> _loadCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Get categories from mock data
    final categories = StoreCategoriesData.getMockCategories();

    if (mounted) {
      setState(() {
        _categories = categories;
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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _categories.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _buildCategoryItem(_categories[index]);
      },
    );
  }
  
  /// Builds a simple category item with a small image on the left
  Widget _buildCategoryItem(StoreCategory category) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          category.imageUrl,
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
        category.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Navigate to category detail
        context.go(StoreRoutesConst.getStoreCategoryRoute(
          widget.storeId,
          category.id,
        ));
      },
    );
  }
}
