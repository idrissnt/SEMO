import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/utils/logger.dart';
import '../../../bloc/store_bloc.dart';
import '../../../bloc/store_event.dart';
import '../../../bloc/store_state.dart';
import '../../../data/models/store_model.dart';
import '../../../../../presentation/widgets/common/loading_view.dart';
import '../../../../../presentation/widgets/common/error_view.dart';
import '../../widgets/store_search_bar.dart';
import 'category_products_screen.dart';
import '../../../../../presentation/widgets/common/gesture_navigation_wrapper.dart';

class StoreAislesScreen extends StatefulWidget {
  final String storeId;

  const StoreAislesScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  State<StoreAislesScreen> createState() => _StoreAislesScreenState();
}

class _StoreAislesScreenState extends State<StoreAislesScreen>
    with AutomaticKeepAliveClientMixin {
  final AppLogger _logger = AppLogger();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _logger
        .debug('StoreAislesScreen: Initializing for store ${widget.storeId}');
    _loadStoreData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStoreData() {
    try {
      _logger.debug('Loading store data for ID: ${widget.storeId}');
      context.read<StoreBloc>().add(LoadStoreByIdEvent(widget.storeId));
    } catch (e) {
      _logger.error('Error loading store data', error: e);
    }
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToCategoryProducts(
      String categoryName, Map<String, dynamic> category) {
    _logger.debug('Navigating to category: $categoryName');
    _logger.debug('category: $category');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GestureNavigationWrapper(
          child: CategoryProductsScreen(
            storeId: widget.storeId,
            categoryName: categoryName,
            category: category,
          ),
          onBackGesture: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: BlocConsumer<StoreBloc, StoreState>(
        listenWhen: (previous, current) =>
            previous is StoreLoading && current is StoreLoaded,
        listener: (context, state) {
          if (state is StoreLoaded) {
            _logger.debug('Store data loaded successfully');
          }
        },
        buildWhen: (previous, current) =>
            current is StoreLoaded ||
            current is StoreLoading ||
            current is StoreError,
        builder: (context, state) {
          if (state is StoreLoading) {
            return const LoadingView();
          } else if (state is StoreError) {
            return ErrorView(
              message: state.message,
              onRetry: _loadStoreData,
            );
          } else if (state is StoreLoaded) {
            final store = state.store;

            final storeModel =
                store is StoreModel ? store : StoreModel.fromEntity(store);

            // Filter categories based on search query
            final List<Map<String, dynamic>> filteredCategories = storeModel
                .categories
                .where((category) =>
                    _searchQuery.isEmpty ||
                    (category['name'] != null &&
                        category['name']
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase())))
                .toList();

            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // App bar with search
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    leadingWidth: 40,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go('/store/${widget.storeId}'),
                      ),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(right: 8.0, left: 8),
                      child: StoreSearchBar(
                        storeName: storeModel.name,
                        controller: _searchController,
                        onChanged: _onSearchQueryChanged,
                      ),
                    ),
                    titleSpacing: 0,
                    bottom: null,
                  ),

                  // Categories list
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: filteredCategories.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No categories found matching "$_searchQuery"'
                                      : 'No categories available in this store',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final category = filteredCategories[index];
                                return _buildCategoryItem(category);
                              },
                              childCount: filteredCategories.length,
                            ),
                          ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final String name = category['name'] ?? 'Category';
    final String imageUrl = category['image_url'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToCategoryProducts(name, category),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Category image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.category,
                                size: 30, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.category, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              // Category name
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Arrow icon
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
