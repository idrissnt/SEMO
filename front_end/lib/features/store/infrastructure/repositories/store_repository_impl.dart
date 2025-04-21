import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/core/utils/result.dart';

import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/domain/exceptions/store_exception_mapper.dart';
import 'package:semo/features/store/domain/exceptions/store_exceptions.dart';
import 'package:semo/features/store/domain/repositories/store_repository.dart';
import 'package:semo/features/store/infrastructure/repositories/services/store_services.dart';

/// Implementation of the StoreRepository interface
/// Handles API communication and data conversion between models and entities
class StoreRepositoryImpl implements StoreRepository {
  final StoreService _storeService;

  StoreRepositoryImpl({
    required ApiClient apiClient,
    required AppLogger logger,
    required StoreExceptionMapper exceptionMapper,
  }) : _storeService = StoreService(
          apiClient: apiClient,
          logger: logger,
          exceptionMapper: exceptionMapper,
        );

  /// Get all store brands
  @override
  Future<Result<List<StoreBrand>, StoreException>> getAllStoreBrands() async {
    try {
      final storeBrands = await _storeService.getAllStoreBrands();
      return Result<List<StoreBrand>, StoreException>.success(storeBrands);
    } catch (e) {
      return _handleStoreError(e, 'Get all store brands');
    }
  }

  /// Find nearby store brands based on address
  @override
  Future<Result<List<NearbyStore>, StoreException>> findNearbyStores({
    required String address,
  }) async {
    try {
      final nearbyStores =
          await _storeService.findNearbyStores(address: address);
      return Result<List<NearbyStore>, StoreException>.success(nearbyStores);
    } catch (e) {
      return _handleStoreError(e, 'Find nearby stores');
    }
  }

  /// Get all products for a specific store
  @override
  Future<Result<List<ProductWithDetails>, StoreException>> getProductsByStore(
      String storeSlug, String storeId) async {
    try {
      final products =
          await _storeService.getProductsByStore(storeSlug, storeId);
      return Result<List<ProductWithDetails>, StoreException>.success(products);
    } catch (e) {
      return _handleStoreError(e, 'Get products by store');
    }
  }

  /// Get products by category path for a specific store
  @override
  Future<Result<List<ProductWithDetails>, StoreException>>
      getStoreProductsForCategory({
    required String storeId,
    required String storeSlug,
  }) async {
    try {
      final products = await _storeService.getStoreProductsForCategory(
        storeId: storeId,
        storeSlug: storeSlug,
      );
      return Result<List<ProductWithDetails>, StoreException>.success(products);
    } catch (e) {
      return _handleStoreError(e, 'Get products by category');
    }
  }

  /// Get autocomplete suggestions for a partial search query
  @override
  Future<Result<List<String>, StoreException>> getAutocompleteSuggestions(
      String query,
      {String? storeId}) async {
    try {
      final suggestions = await _storeService.getAutocompleteSuggestions(
        query,
        storeId: storeId,
      );
      return Result<List<String>, StoreException>.success(suggestions);
    } catch (e) {
      return _handleStoreError(e, 'Get autocomplete suggestions');
    }
  }

  /// Search for products globally or within a specific store
  @override
  Future<Result<SearchResult, StoreException>> searchProducts({
    required String query,
    String? storeId,
    int? page,
    int? pageSize,
  }) async {
    try {
      final searchResult = await _storeService.searchProducts(
        query: query,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );
      return Result<SearchResult, StoreException>.success(searchResult);
    } catch (e) {
      return _handleStoreError(e, 'Search products');
    }
  }

  /// Helper method to handle store errors and return appropriate Result objects
  /// @param e The exception that was thrown
  /// @param operation The name of the operation being performed
  /// @returns A Result.failure with the appropriate exception
  Result<T, StoreException> _handleStoreError<T>(dynamic e, String operation) {
    // Handle domain-specific exceptions
    if (e is StoreException) {
      // Store exceptions can be directly returned
      return Result.failure(e);
    } else {
      // Fallback for unexpected exceptions
      return Result.failure(GenericStoreException(
        'Unexpected error during $operation: ${e.toString()}',
      ));
    }
  }
}
