import 'package:semo/core/utils/result.dart';
import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/domain/exceptions/store_exceptions.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';

/// Use cases for the Home Screen
class HomeStoreUseCases {
  final StoreRepository _storeRepository;

  HomeStoreUseCases(this._storeRepository);

  /// Get all store brands
  Future<Result<List<StoreBrand>, StoreException>> getAllStoreBrands() {
    return _storeRepository.getAllStoreBrands();
  }

  /// Find nearby store brands based on user address
  Future<Result<List<NearbyStore>, StoreException>> findNearbyStores({required String address}) {
    return _storeRepository.findNearbyStores(address: address);
  }

  /// Get products by category for a specific store
  Future<Result<List<ProductWithDetails>, StoreException>> getProductsByCategory(
      {required String storeSlug, required String storeId}) {
    return _storeRepository.getStoreProductsForCategory(
        storeSlug: storeSlug, storeId: storeId);
  }

  /// Get autocomplete suggestions globally (without store filter)
  Future<Result<List<String>, StoreException>> getAutocompleteSuggestions(String query) {
    // No storeId means global search
    return _storeRepository.getAutocompleteSuggestions(query);
  }

  /// Search products globally
  Future<Result<SearchResult, StoreException>> searchProducts({
    required String query,
    int? page,
    int? pageSize,
  }) {
    return _storeRepository.searchProducts(
      query: query,
      page: page,
      pageSize: pageSize,
    );
  }
}
