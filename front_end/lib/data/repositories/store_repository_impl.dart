import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/store_repository.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final http.Client client;
  final Box<StoreModel> storeBox;
  final String baseUrl = AppConfig.apiBaseUrl;
  final AppLogger _logger = AppLogger();

  // Cache configuration
  static const Duration _cacheDuration = Duration(hours: 1);
  static const int _maxCacheSize = 50;

  StoreRepositoryImpl({
    required this.client,
    required this.storeBox,
  });

  // Check if cached stores are still valid
  bool _areCachedStoresValid() {
    if (storeBox.isEmpty) return false;

    // Check the most recently cached store
    final latestStore = storeBox.values.toList().last;
    return DateTime.now().difference(latestStore.cachedAt) < _cacheDuration;
  }

  // Clear entire store cache
  Future<void> clearStoreCache() async {
    await storeBox.clear();
    _logger.info('Store cache completely cleared');
  }

  // Remove old cached stores to prevent memory bloat
  Future<void> _manageCacheSize() async {
    if (storeBox.length > _maxCacheSize) {
      // Remove the oldest stores first
      final sortedStores = storeBox.values.toList()
        ..sort((a, b) => a.cachedAt.compareTo(b.cachedAt));

      final storesToRemove = sortedStores.take(storeBox.length - _maxCacheSize);
      for (var store in storesToRemove) {
        await storeBox.delete(store.id);
      }
      _logger.info('Removed ${storesToRemove.length} old stores from cache');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    return {'Content-Type': 'application/json'};
  }

  @override
  Future<List<Store>> getStores({
    String? search,
    bool? isOpen,
    double? minRating,
    bool? isBigStore,
    bool forceRefresh = false,
  }) async {
    try {
      // Check if we can use cached stores
      if (!forceRefresh && _areCachedStoresValid()) {
        final cachedStores = storeBox.values.toList();
        _logger.debug('Returning ${cachedStores.length} valid cached stores');
        return cachedStores;
      }

      _logger.debug('Attempting to retrieve stores with parameters');

      final queryParams = {
        if (search != null) 'search': search,
        if (isOpen != null) 'is_open': isOpen.toString(),
        if (minRating != null) 'min_rating': minRating.toString(),
        if (isBigStore != null) 'is_big_store': isBigStore.toString(),
      };

      final uri =
          Uri.parse('$baseUrl/stores/').replace(queryParameters: queryParams);
      _logger.debug('Full Store Retrieval URL: $uri');

      final response = await client
          .get(
        uri,
        headers: await _getHeaders(),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.error('Store retrieval request timed out');
          throw TimeoutException('Store retrieval request timed out');
        },
      );

      _logger.debug('Store Response Details: ${response.statusCode} ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logger.debug('Total stores in raw response: ${data.length}');

        final List<StoreModel> stores = [];

        for (var storeJson in data) {
          try {
            final store = StoreModel.fromJson(storeJson);

            if (isBigStore == null || store.isBigStore == isBigStore) {
              stores.add(store);
            }
          } catch (e) {
            _logger.error('Error parsing individual store', error: e);
            continue;
          }
        }

        _logger.debug('Stores after parsing and filtering: ${stores.length}');

        try {
          // Clear existing stores that don't match current filter
          final existingStores = storeBox.values.toList();
          for (var existingStore in existingStores) {
            if (isBigStore == null || existingStore.isBigStore == isBigStore) {
              await storeBox.delete(existingStore.id);
            }
          }

          // Add new stores to cache
          for (var store in stores) {
            await storeBox.put(store.id, store);
          }

          // Manage cache size
          await _manageCacheSize();

          _logger.info('Stores successfully cached in Hive');
        } catch (e) {
          _logger.error('Error caching stores', error: e);
        }

        return stores;
      } else if (response.statusCode == 401) {
        _logger.error('Unauthorized access when retrieving stores');
        throw const UnauthorizedException('Unauthorized access');
      } else {
        _logger.error('Server returned non-200 status code: ${response.statusCode}');

        final cachedStores = storeBox.values.toList();
        if (cachedStores.isNotEmpty) {
          _logger.debug('Returning cached stores: ${cachedStores.length}');
          return cachedStores;
        }

        throw ServerException(
            message: 'Failed to load stores: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      _logger.error('Socket exception during store retrieval', error: e);

      final cachedStores = storeBox.values.toList();
      if (cachedStores.isNotEmpty) {
        _logger.debug('Returning cached stores due to network issue: ${cachedStores.length}');
        return cachedStores;
      }

      throw const NetworkException('No internet connection');
    } on TimeoutException catch (e) {
      _logger.error('Timeout during store retrieval', error: e);

      final cachedStores = storeBox.values.toList();
      if (cachedStores.isNotEmpty) {
        _logger.debug('Returning cached stores due to timeout: ${cachedStores.length}');
        return cachedStores;
      }

      throw const NetworkException('Request timed out');
    } catch (e, stackTrace) {
      _logger.error('Unexpected error during store retrieval', error: e, stackTrace: stackTrace);

      final cachedStores = storeBox.values.toList();
      if (cachedStores.isNotEmpty) {
        _logger.debug('Returning cached stores: ${cachedStores.length}');
        return cachedStores;
      }

      throw UnexpectedException(e.toString());
    }
  }

  @override
  Future<Store> getStoreById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/stores/$id/');
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return StoreModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException('Store not found');
      } else {
        throw const ServerException(message: 'Failed to load store details');
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  @override
  Future<List<Product>> getStoreProducts(String storeId) async {
    try {
      final uri = Uri.parse('$baseUrl/stores/$storeId/products/');
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException('Products not found');
      } else {
        throw const ServerException(message: 'Failed to load store products');
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  @override
  Future<List<Category>> getStoreCategories(String storeId) async {
    try {
      final uri = Uri.parse('$baseUrl/stores/$storeId/categories/');
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException('Categories not found');
      } else {
        throw const ServerException(message: 'Failed to load store categories');
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  @override
  Future<Store> rateStore(String storeId, double rating) async {
    try {
      final uri = Uri.parse('$baseUrl/stores/$storeId/rate/');
      final response = await client.post(
        uri,
        body: json.encode({'rating': rating}),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return StoreModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException('Store not found');
      } else {
        throw const ServerException(message: 'Failed to rate store');
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }
}
