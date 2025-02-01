import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final http.Client client;
  final String baseUrl = AppConfig.apiBaseUrl;
  final AppLogger _logger = AppLogger();

  StoreRepositoryImpl({
    required this.client,
  });

  Future<Map<String, String>> _getHeaders() async {
    return {'Content-Type': 'application/json'};
  }

  @override
  Future<Map<String, List<Store>>> getStores({
    String? name,
    bool? isBigStore,
  }) async {
    try {
      _logger.debug(
          '[store_repository_impl.dart] Attempting to get stores from api');

      final fullUrl = '$baseUrl/stores/full_details/';
      _logger.debug('[store_repository_impl.dart] Calling URL: $fullUrl');

      final response = await client
          .get(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.error(
              '[store_repository_impl.dart] Store retrieval request timed out');
          throw TimeoutException('Store retrieval request timed out');
        },
      );

      _logger.debug(
          '[store_repository_impl.dart] Store Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<StoreModel> storesByName = [];
        final List<StoreModel> bigStores = [];
        final List<StoreModel> smallStores = [];

        for (var storeJson in data) {
          try {
            final store = StoreModel.fromJson(storeJson);

            if (store.isBigStore == isBigStore) {
              _logger.debug('Getting Store big : ${store.isBigStore}');

              bigStores.add(store);
            }
            if (name != null &&
                store.name.toLowerCase() == name.toLowerCase()) {
              _logger.debug('Getting Store: ${store.name}');

              storesByName.add(store);
            }
            if (store.isBigStore != isBigStore) {
              _logger.debug('Getting Store small : ${store.isBigStore}');

              smallStores.add(store);
            }
          } catch (e) {
            _logger.error('[store_repository_impl.dart] Error parsing store',
                error: e);
            continue;
          }
        }

        final storesMap = {
          'bigStores': bigStores,
          'smallStores': smallStores,
          'storesByName': storesByName
        };

        _logger.debug(
            '[store_repository_impl.dart] Returning stores: big=${bigStores.length}, small=${smallStores.length}, byName=${storesByName.length}');

        return storesMap;
      } else {
        _logger.error(
            '[store_repository_impl.dart] Failed to retrieve stores. Status code: ${response.statusCode}');
        return {}; // Return an empty map
      }
    } catch (e) {
      _logger.error('[store_repository_impl.dart] Error retrieving stores',
          error: e);
      return {}; // Return an empty map in case of any other errors
    }
  }
}
