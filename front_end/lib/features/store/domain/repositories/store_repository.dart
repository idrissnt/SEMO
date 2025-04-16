import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/entities/store.dart';

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
  Future<List<ProductWithDetails>> getProductsByStore(
      String storeSlug, String storeId);

  /// Get products by category path for a specific store
  Future<List<ProductWithDetails>> getStoreProductsForCategory({
    required String storeId,
    required String storeSlug,
  });

  /// Get autocomplete suggestions for a partial search query globally or within a specific store
  Future<List<String>> getAutocompleteSuggestions(String query,
      {String? storeId});

  /// Search for products globally or within a specific store
  Future<SearchResult> searchProducts({
    required String query,
    String? storeId,
    int? page,
    int? pageSize,
  });
}
