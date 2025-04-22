import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/api_endpoints/api_enpoints.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/domain/exceptions/store_exception_mapper.dart';
import 'package:semo/features/store/infrastructure/models/product_model.dart';
import 'package:semo/features/store/infrastructure/models/store_model.dart';

/// Handles store-related API operations
/// Follows the same pattern as AuthService
class StoreService {
  final ApiClient _apiClient;
  final AppLogger _logger;
  final StoreExceptionMapper _exceptionMapper;

  StoreService({
    required ApiClient apiClient,
    required AppLogger logger,
    required StoreExceptionMapper exceptionMapper,
  })  : _apiClient = apiClient,
        _logger = logger,
        _exceptionMapper = exceptionMapper;

  /// Get all store brands
  Future<List<StoreBrand>> getAllStoreBrands() async {
    try {
      _logger.debug('Fetching store brands');
      final data =
          await _apiClient.get<List<dynamic>>(StoreApiRoutes.storeBrands);

      _logger.debug('Successfully fetched ${data.length} store brands');
      return data
          .map((json) => StoreBrandModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch store brands', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Find nearby store brands based on address
  Future<List<NearbyStore>> findNearbyStores({
    required String address,
  }) async {
    try {
      _logger.debug('Finding nearby stores for address: $address');

      final data = await _apiClient.get<List<dynamic>>(
        StoreApiRoutes.getStoreBrandsNearby(address),
      );

      _logger.debug('Successfully found ${data.length} nearby stores');
      return data
          .map((json) => NearbyStoreModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Failed to find nearby stores', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Get all products for a specific store
  Future<List<ProductWithDetails>> getProductsByStore(
      String storeSlug, String storeId) async {
    try {
      _logger.debug('Fetching products for store: $storeId');

      final data = await _apiClient.get<List<dynamic>>(
        StoreApiRoutes.getProductsByStore(storeSlug),
        queryParameters: {'store_id': storeId},
      );

      _logger.debug(
          'Successfully fetched ${data.length} products for store: $storeId');
      return data
          .map((json) => ProductWithDetailsModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch products for store', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Get products by category path for a specific store
  Future<List<ProductWithDetails>> getStoreProductsForCategory({
    required String storeId,
    required String storeSlug,
  }) async {
    try {
      _logger.debug('Fetching products by category for store: $storeId');

      final data = await _apiClient.get<List<dynamic>>(
        StoreApiRoutes.getStoreProductsForCategory(storeSlug),
        queryParameters: {
          'store_id': storeId,
        },
      );

      _logger.debug(
          'Successfully fetched ${data.length} products by category for store: $storeId');
      return data
          .map((json) => ProductWithDetailsModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Failed to fetch products by category for store', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Get autocomplete suggestions for a partial search query
  Future<List<String>> getAutocompleteSuggestions(String query,
      {String? storeId}) async {
    try {
      _logger.debug('Getting autocomplete suggestions for query: $query');

      // Build query parameters
      final queryParams = {
        'q': query,
      };

      // Add store_id if provided
      if (storeId != null) {
        queryParams['store_id'] = storeId;
      }

      final data = await _apiClient.get<List<dynamic>>(
        StoreSearchApiRoutes.autocomplete,
        queryParameters: queryParams,
      );

      _logger.debug(
          'Successfully fetched ${data.length} autocomplete suggestions');
      return data.map((item) => item['name'].toString()).toList();
    } catch (e) {
      _logger.error('Failed to get autocomplete suggestions', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }

  /// Search for products globally or within a specific store
  Future<SearchResult> searchProducts({
    required String query,
    String? storeId,
    int? page,
    int? pageSize,
  }) async {
    try {
      _logger.debug('Searching products with query: $query');

      // Build query parameters
      final queryParams = {
        'q': query,
      };

      // Add store_id if provided
      if (storeId != null) {
        queryParams['store_id'] = storeId;
      }

      // Add pagination parameters if provided
      if (page != null) {
        queryParams['page'] = page.toString();
      }

      if (pageSize != null) {
        queryParams['page_size'] = pageSize.toString();
      }

      final responseData = await _apiClient.get<Map<String, dynamic>>(
        StoreSearchApiRoutes.searchProducts,
        queryParameters: queryParams,
      );

      _logger.debug('Successfully searched products with query: $query');

      final resultsData = responseData['results'];
      final metadataData = responseData['metadata'];

      // Parse metadata based on search type
      final searchMetadata = storeId != null
          ? SearchMetadata(
              totalProducts: metadataData['total_products'],
            )
          : SearchMetadata(
              storeCounts: Map<String, int>.from(metadataData['store_counts']),
            );

      // Check if this is a store-specific search or global search
      if (storeId != null) {
        // Store-specific search - results is a list of products
        final List<dynamic> productsData = resultsData;
        final products = productsData
            .map((json) => ProductWithDetailsModel.fromJson(json).toEntity())
            .toList();

        return SearchResult(
          products: products,
          metadata: searchMetadata,
        );
      } else {
        // Global search - results is a map of store IDs to store data
        final Map<String, dynamic> storeResultsData = resultsData;
        final Map<String, StoreSearchResult> storeResults = {};

        storeResultsData.forEach((storeId, storeData) {
          final storeInfo = storeData['store_info'];
          final storeBrand = StoreBrand(
            id: storeInfo['id'],
            name: storeInfo['name'],
            slug: storeInfo['slug'] ?? '',
            type: storeInfo['type'] ?? '',
            imageLogo: storeInfo['image_logo'] ?? '',
            imageBanner: storeInfo['image_banner'] ?? '',
          );

          final List<dynamic> productsData = storeData['products'];
          final products = productsData
              .map((json) => ProductWithDetailsModel.fromJson(json).toEntity())
              .toList();

          storeResults[storeId] = StoreSearchResult(
            store: storeBrand,
            categoryPath: storeData['category_path'],
            products: products,
          );
        });

        return SearchResult(
          storeResults: storeResults,
          metadata: searchMetadata,
        );
      }
    } catch (e) {
      _logger.error('Failed to search products', error: e);
      return _exceptionMapper.mapApiExceptionToDomainException(e);
    }
  }
}
