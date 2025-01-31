import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final http.Client client;
  final AppLogger _logger = AppLogger();

  CategoryRepositoryImpl({
    required this.client,
  });

  @override
  Future<List<Category>> getCategories({
    String? storeId,
    bool? rootOnly,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (storeId != null) queryParams['store_id'] = storeId;
      if (rootOnly != null) queryParams['root_only'] = rootOnly.toString();

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/products/categories/')
          .replace(queryParameters: queryParams);
      
      _logger.debug('Fetching categories with URI: $uri');
      
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        _logger.debug('Total categories retrieved: ${jsonList.length}');
        
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        _logger.error('Failed to load categories. Status code: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load categories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.error('Error fetching categories', error: e);
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<Category> getCategoryById(String id) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/products/categories/$id/');
      
      _logger.debug('Fetching category with ID: $id');
      
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final categoryJson = json.decode(response.body);
        
        _logger.debug('Category retrieved successfully');
        
        return CategoryModel.fromJson(categoryJson);
      } else {
        _logger.error('Failed to load category. Status code: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load category',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.error('Error fetching category by ID', error: e);
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<Product>> getCategoryProducts(String categoryId) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/products/categories/$categoryId/products/');
      
      _logger.debug('Fetching products for category ID: $categoryId');
      
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        _logger.debug('Total products retrieved for category: ${jsonList.length}');
        
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        _logger.error('Failed to load category products. Status code: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load category products',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.error('Error fetching category products', error: e);
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<Category>> getCategorySubcategories(String categoryId) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/products/categories/$categoryId/subcategories/');
      
      _logger.debug('Fetching subcategories for category ID: $categoryId');
      
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        _logger.debug('Total subcategories retrieved for category: ${jsonList.length}');
        
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        _logger.error('Failed to load category subcategories. Status code: ${response.statusCode}');
        throw ServerException(
          message: 'Failed to load category subcategories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.error('Error fetching category subcategories', error: e);
      throw ServerException(
        message: e.toString(),
      );
    }
  }
}
