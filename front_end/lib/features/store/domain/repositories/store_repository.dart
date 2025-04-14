import '../entities/product.dart';
import '../entities/search_result.dart';
import '../entities/store.dart';

/// Repository interface for store-related operations
/// Following clean architecture, this defines the contract that data layer must implement
abstract class StoreRepository {
  /// Get all store brands
  Future<List<StoreBrand>> getAllStoreBrands();

  /// Find nearby store brands based on user address
  Future<List<NearbyStore>> findNearbyStores({
    required String address,
  });

  /// Get all products for a specific store
  Future<List<ProductWithDetails>> getProductsByStoreId(String storeId);

  /// Get products by category path for a specific store
  Future<List<ProductWithDetails>> getProductsByCategory({
    required String storeId,
  });

  /// Get autocomplete suggestions for a partial search query
  Future<List<String>> getAutocompleteSuggestions(String query);

  /// Search for products globally or within a specific store
  Future<SearchResult> searchProducts({
    required String query,
    String? storeId,
    int? page,
    int? pageSize,
  });
}
