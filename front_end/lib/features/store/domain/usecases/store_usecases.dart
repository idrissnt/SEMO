import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';

/// Use cases for the Store Screen
class StoreUseCases {
  final StoreRepository _storeRepository;

  StoreUseCases(this._storeRepository);

  /// Get all products for a specific store
  Future<List<ProductWithDetails>> getProductsByStore(
      String storeSlug, String storeId) {
    return _storeRepository.getProductsByStore(storeSlug, storeId);
  }

  /// Get autocomplete suggestions for a specific store
  Future<List<String>> getAutocompleteSuggestions(
      String query, String storeId) {
    return _storeRepository.getAutocompleteSuggestions(query, storeId: storeId);
  }

  /// Search products within a specific store
  Future<SearchResult> searchProducts({
    required String query,
    required String storeId,
    int? page,
    int? pageSize,
  }) {
    return _storeRepository.searchProducts(
      query: query,
      storeId: storeId,
      page: page,
      pageSize: pageSize,
    );
  }
}
