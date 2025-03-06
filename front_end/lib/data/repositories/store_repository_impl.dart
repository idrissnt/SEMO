import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final http.Client client;
  final String baseUrl = AppConfig.apiBaseUrl;
  final String allStoresUrl = '${AppConfig.apiBaseUrl}${AppConfig.allStores}';
  final String storeDetailsUrl =
      '${AppConfig.apiBaseUrl}${AppConfig.storesFullDetails}';
  final AppLogger _logger = AppLogger();

  StoreRepositoryImpl({
    http.Client? client,
  }) : client = client ?? http.Client();

  @override
  Future<Map<String, List<Store>>> getStores({
    String? name,
    bool? isBigStore,
  }) async {
    try {
      _logger.debug(
          '[store_repository_impl.dart] Getting stores with name: $name, isBigStore: $isBigStore');

      _logger.debug(
          '[store_repository_impl.dart] Attempting to get lightweight stores from api');

      _logger.debug('[store_repository_impl.dart] Calling URL: $allStoresUrl');

      final response = await client
          .get(
        Uri.parse(allStoresUrl),
        headers: await _getHeaders(),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      _logger.debug(
          '[store_repository_impl.dart] Got response with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle the response as a List instead of a Map
        final List<dynamic> responseData = json.decode(response.body);
        _logger.debug(
            '[store_repository_impl.dart] Received list with ${responseData.length} stores');

        // Convert List to StoreModel objects
        final List<Store> stores = responseData
            .map((storeJson) => StoreModel.fromJson(storeJson))
            .toList();

        // Create the map format expected by the application
        final Map<String, List<Store>> result = {};

        // Filter by name if provided
        if (name != null && name.isNotEmpty) {
          _logger.debug(
              '[store_repository_impl.dart] Filtering stores by name: $name');
          final storesByName = stores
              .where((store) =>
                  store.name.toLowerCase().contains(name.toLowerCase()))
              .toList();
          result['storesByName'] = storesByName;
        } else {
          result['storesByName'] = [];
        }

        // Filter by isBigStore
        final bigStores =
            stores.where((store) => store.isBigStore == true).toList();
        final smallStores =
            stores.where((store) => store.isBigStore == false).toList();

        result['bigStores'] = bigStores;
        result['smallStores'] = smallStores;

        _logger.debug(
            '[store_repository_impl.dart] Categorized stores: big=${bigStores.length}, small=${smallStores.length}, byName=${result['storesByName']?.length}');

        return result;
      } else {
        throw Exception(
            'Failed to load stores. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('[store_repository_impl.dart] Error getting stores',
          error: e);
      rethrow;
    }
  }

  @override
  Future<Store?> getStoreById(String storeId) async {
    try {
      _logger.debug(
          '[store_repository_impl.dart] Getting full details for store ID: $storeId');

      final fullUrl = '$storeDetailsUrl?store_id=$storeId';
      _logger.debug('[store_repository_impl.dart] Calling URL: $fullUrl');

      final response = await client
          .get(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      _logger.debug(
          '[store_repository_impl.dart] Got response with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle the response as a List
        final List<dynamic> responseData = json.decode(response.body);

        // Find the store with the matching ID
        for (var storeJson in responseData) {
          final store = StoreModel.fromJson(storeJson);
          if (store.id == storeId) {
            _logger.debug(
                '[store_repository_impl.dart] Found store with ID $storeId');
            return store;
          }
        }

        // If we get here, the store wasn't found
        _logger.warning(
            '[store_repository_impl.dart] Store with ID $storeId not found in response');
        return null;
      } else {
        throw Exception(
            'Failed to load store details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('[store_repository_impl.dart] Error getting store by ID',
          error: e);
      rethrow;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };

    // TODO: Add authentication token to headers when implemented
    // final token = await _tokenStorage.getToken();
    // if (token != null) {
    //   headers['Authorization'] = 'Bearer $token';
    // }
    return headers;
  }
}
