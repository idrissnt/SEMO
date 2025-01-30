import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final http.Client client;

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
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to load categories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<Category> getCategoryById(String id) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/products/categories/$id/'),
      );

      if (response.statusCode == 200) {
        return CategoryModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException(
          message: 'Failed to load category details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<Product>> getCategoryProducts(String categoryId) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/products/categories/$categoryId/products/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to load category products',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<Category>> getCategorySubcategories(String categoryId) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/products/categories/$categoryId/subcategories/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to load category subcategories',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }
}
