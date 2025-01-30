import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/store_repository.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final http.Client client;
  final String baseUrl = AppConfig.apiBaseUrl;

  StoreRepositoryImpl({
    required this.client,
  });

  Future<Map<String, String>> _getHeaders() async {
    return {'Content-Type': 'application/json'};
  }

  @override
  Future<List<Store>> getStores({
    String? search,
    bool? isOpen,
    double? minRating,
    bool? isBigStore,
  }) async {
    try {
      final queryParams = {
        if (search != null) 'search': search,
        if (isOpen != null) 'is_open': isOpen.toString(),
        if (minRating != null) 'min_rating': minRating.toString(),
        if (isBigStore != null) 'is_big_store': isBigStore.toString(),
      };

      final uri =
          Uri.parse('$baseUrl/stores/').replace(queryParameters: queryParams);
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StoreModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException('Stores not found');
      } else {
        throw const ServerException(message: 'Failed to load stores');
      }
    } on SocketException {
      throw const NetworkException('No internet connection');
    } catch (e) {
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
