import 'package:dio/dio.dart';
import 'package:semo/core/domain/services/api_client.dart';
import 'package:semo/core/infrastructure/services/api/api_routes.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/store/domain/repositories/store_repository.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/domain/entities/product.dart';
import 'package:semo/features/store/domain/entities/search_result.dart';
import 'package:semo/features/store/domain/exceptions/store_exceptions.dart';

import 'package:semo/features/store/infrastructure/models/store_model.dart';
import 'package:semo/features/store/infrastructure/models/product_model.dart';

/// Implementation of the StoreRepository interface
/// Handles API communication and data conversion between models and entities
class StoreRepositoryImpl implements StoreRepository {
  final ApiClient _apiClient;
  final AppLogger _logger;

  StoreRepositoryImpl({
    required ApiClient apiClient,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _logger = logger;

  /// Get all store brands
  @override
  Future<List<StoreBrand>> getAllStoreBrands() async {
    try {
      _logger.info('Fetching store brands, url: ${StoreApiRoutes.storeBrands}');
      final data =
          await _apiClient.get<List<dynamic>>(StoreApiRoutes.storeBrands);
      return data
          .map((json) => StoreBrandModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Error getting store brands', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw StoreNetworkException(
              'Network error while fetching store brands', e);
        } else if (e.response?.statusCode == 404) {
          throw StoreNotFoundException('Store brands not found', e);
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          throw StoreAuthenticationException(
              'Authentication required to access store brands', e);
        }
      }
      throw StoreException('Failed to get store brands', e);
    }
  }

  /// Find nearby store brands based on address
  @override
  Future<List<NearbyStore>> findNearbyStores({
    required String address,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'address': address,
      };

      final data = await _apiClient.get<List<dynamic>>(
        StoreApiRoutes.nearbyStores,
        queryParameters: queryParams,
      );

      return data
          .map((json) => NearbyStoreModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Error finding nearby stores', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw StoreNetworkException(
              'Network error while finding nearby stores', e);
        } else if (e.response?.statusCode == 404) {
          throw StoreNotFoundException(
              'No nearby stores found for the given address', e);
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          throw StoreAuthenticationException(
              'Authentication required to find nearby stores', e);
        }
      }
      throw StoreException('Failed to find nearby stores', e);
    }
  }

  /// Get all products for a specific store
  @override
  Future<List<ProductWithDetails>> getProductsByStore(
      String storeSlug, String storeId) async {
    try {
      final data = await _apiClient.get<List<dynamic>>(
        StoreApiRoutes.getProductsByStore(storeSlug),
        queryParameters: {'store_id': storeId},
      );

      return data
          .map((json) => ProductWithDetailsModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Error getting products by store ID', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw StoreNetworkException(
              'Network error while fetching products for store $storeId', e);
        } else if (e.response?.statusCode == 404) {
          throw ProductNotFoundException(
              'No products found for store $storeId', e);
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          throw StoreAuthenticationException(
              'Authentication required to access products', e);
        }
      }
      throw StoreException('Failed to get products for store $storeId', e);
    }
  }

  /// Get products by category path for a specific store
  @override
  Future<List<ProductWithDetails>> getStoreProductsForCategory({
    required String storeId,
    required String storeSlug,
  }) async {
    try {
      final data = await _apiClient.get<List<dynamic>>(
        StoreApiRoutes.getStoreProductsForCategory(storeSlug),
        queryParameters: {
          'store_id': storeId,
        },
      );

      return data
          .map((json) => ProductWithDetailsModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      _logger.error('Error getting products by category', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw StoreNetworkException(
              'Network error while fetching products by category for store $storeId',
              e);
        } else if (e.response?.statusCode == 404) {
          throw ProductNotFoundException(
              'No products found in the specified category for store $storeId',
              e);
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          throw StoreAuthenticationException(
              'Authentication required to access category products', e);
        }
      }
      throw StoreException(
          'Failed to get products by category for store $storeId', e);
    }
  }

  /// Get autocomplete suggestions for a partial search query
  @override
  Future<List<String>> getAutocompleteSuggestions(String query,
      {String? storeId}) async {
    try {
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

      return data.map((item) => item['name'].toString()).toList();
    } catch (e) {
      _logger.error('Error getting autocomplete suggestions', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw StoreNetworkException(
              'Network error while fetching autocomplete suggestions', e);
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          throw StoreAuthenticationException(
              'Authentication required to access autocomplete suggestions', e);
        }
      }
      throw StoreSearchException(
          'Failed to get autocomplete suggestions for "$query"', e);
    }
  }

  /// Search for products globally or within a specific store
  @override
  Future<SearchResult> searchProducts({
    required String query,
    String? storeId,
    int? page,
    int? pageSize,
  }) async {
    try {
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
            slug: '', // Not provided in the API response
            type: '', // Not provided in the API response
            imageLogo: storeInfo['image_logo'],
            imageBanner: '', // Not provided in the API response
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
      _logger.error('Error searching products', error: e);
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw StoreNetworkException(
              'Network error while searching products', e);
        } else if (e.response?.statusCode == 404) {
          throw ProductNotFoundException(
              'No products found matching the search criteria', e);
        } else if (e.response?.statusCode == 401 ||
            e.response?.statusCode == 403) {
          throw StoreAuthenticationException(
              'Authentication required to search products', e);
        }
      }
      throw StoreSearchException('Failed to search products for "$query"', e);
    }
  }
}
