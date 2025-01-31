import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final http.Client client;
  final AppLogger _logger = AppLogger();

  ProductRepositoryImpl({
    required this.client,
  });

  @override
  Future<List<Product>> getProducts({
    String? storeId,
    String? categoryId,
    String? parentCategoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? isAvailable,
    bool? isSeasonal,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (storeId != null) queryParams['store_id'] = storeId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (parentCategoryId != null) {
        queryParams['parent_category_id'] = parentCategoryId;
      }
      if (search != null) queryParams['search'] = search;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (isAvailable != null) {
        queryParams['is_available'] = isAvailable.toString();
      }
      if (isSeasonal != null) {
        queryParams['is_seasonal'] = isSeasonal.toString();
      }

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/products/')
          .replace(queryParameters: queryParams);
      
      _logger.debug('Fetching products with URI: $uri');
      
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        _logger.debug('Total products retrieved: ${jsonList.length}');
        
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        _logger.error('Failed to load products. Status code: ${response.statusCode}');
        throw ServerException(
            message: 'Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Error fetching products', error: e);
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/products/$id/'),
      );

      if (response.statusCode == 200) {
        _logger.debug('Product retrieved with id: $id');
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        _logger.error('Failed to load product details. Status code: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load product details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.error('Error fetching product by id', error: e);
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductAvailability(String productId) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/products/$productId/availability/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _logger.debug('Product availability retrieved for id: $productId');
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        _logger.error('Failed to load product availability. Status code: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load product availability',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.error('Error fetching product availability', error: e);
      rethrow;
    }
  }

  @override
  Future<List<Product>> getSeasonalProducts() async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/products/seasonal/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _logger.debug('Seasonal products retrieved');
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        _logger.error('Failed to load seasonal products. Status code: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load seasonal products',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.error('Error fetching seasonal products', error: e);
      rethrow;
    }
  }
}
