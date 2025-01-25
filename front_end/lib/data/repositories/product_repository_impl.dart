// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/auth_service.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final http.Client client;
  final AuthService? authService;

  ProductRepositoryImpl({
    required this.client,
    this.authService,
  });

  Future<Map<String, String>> _getHeaders() async {
    final baseHeaders = {'Content-Type': 'application/json'};

    if (authService != null) {
      try {
        final token = await authService!.getAccessToken();
        if (token != null && token.isNotEmpty) {
          return {
            ...baseHeaders,
            'Authorization': 'Bearer $token',
          };
        }
      } catch (e) {
        print('Error getting auth token: $e');
      }
    }

    return baseHeaders;
  }

  @override
  Future<List<Product>> getSeasonalProducts() async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/products/seasonal/';
      print('Fetching Seasonal Products URL: $url');
      print('Seasonal Products Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Seasonal Products Response Status: ${response.statusCode}');
      print('Seasonal Products Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        // Add robust error handling for each product
        final processedProducts = <Product>[];
        for (var productJson in jsonList) {
          try {
            // Ensure all required fields are present and of correct type
            final product = ProductModel.fromJson({
              'id': productJson['id'] ?? 0,
              'name': productJson['name'] ?? 'Unknown Product',
              'image_url': productJson['image_url'] ?? '',
              'price': productJson['price'] ?? 0.0,
              'is_seasonal_product': productJson['is_seasonal_product'] ?? false,
              'season': productJson['season'],
              'description': productJson['description'] ?? '',
            });
            processedProducts.add(product);
          } catch (e) {
            print('Error processing individual product: $e');
            print('Problematic product JSON: $productJson');
          }
        }

        return processedProducts;
      } else {
        throw Exception('Failed to load seasonal products: ${response.body}');
      }
    } catch (e) {
      print('Error in getSeasonalProducts: $e');
      throw Exception('Failed to load seasonal products: $e');
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/products/$id/';
      print('Fetching Product by ID URL: $url');
      print('Product by ID Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Product by ID Response Status: ${response.statusCode}');
      print('Product by ID Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final productJson = json.decode(response.body);
          final product = ProductModel.fromJson({
            'id': productJson['id'] ?? 0,
            'name': productJson['name'] ?? 'Unknown Product',
            'image_url': productJson['image_url'] ?? '',
            'price': productJson['price'] ?? 0.0,
            'is_seasonal_product': productJson['is_seasonal_product'] ?? false,
            'season': productJson['season'],
            'description': productJson['description'] ?? '',
          });
          return product;
        } catch (e) {
          print('Error processing product: $e');
          print('Problematic product JSON: ${response.body}');
          throw Exception('Failed to load product: $e');
        }
      } else {
        throw Exception('Failed to load product: ${response.body}');
      }
    } catch (e) {
      print('Error in getProductById: $e');
      throw Exception('Failed to load product: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/products/search/?q=$query';
      print('Searching Products URL: $url');
      print('Searching Products Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Searching Products Response Status: ${response.statusCode}');
      print('Searching Products Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        // Add robust error handling for each product
        final processedProducts = <Product>[];
        for (var productJson in jsonList) {
          try {
            // Ensure all required fields are present and of correct type
            final product = ProductModel.fromJson({
              'id': productJson['id'] ?? 0,
              'name': productJson['name'] ?? 'Unknown Product',
              'image_url': productJson['image_url'] ?? '',
              'price': productJson['price'] ?? 0.0,
              'is_seasonal_product': productJson['is_seasonal_product'] ?? false,
              'season': productJson['season'],
              'description': productJson['description'] ?? '',
            });
            processedProducts.add(product);
          } catch (e) {
            print('Error processing individual product: $e');
            print('Problematic product JSON: $productJson');
          }
        }

        return processedProducts;
      } else {
        throw Exception('Failed to search products: ${response.body}');
      }
    } catch (e) {
      print('Error in searchProducts: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByStore(int storeId) async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/stores/$storeId/products/';
      print('Fetching Products by Store URL: $url');
      print('Products by Store Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Products by Store Response Status: ${response.statusCode}');
      print('Products by Store Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        
        // Add robust error handling for each product
        final processedProducts = <Product>[];
        for (var productJson in jsonList) {
          try {
            // Ensure all required fields are present and of correct type
            final product = ProductModel.fromJson({
              'id': productJson['id'] ?? 0,
              'name': productJson['name'] ?? 'Unknown Product',
              'image_url': productJson['image_url'] ?? '',
              'price': productJson['price'] ?? 0.0,
              'is_seasonal_product': productJson['is_seasonal_product'] ?? false,
              'season': productJson['season'],
              'description': productJson['description'] ?? '',
            });
            processedProducts.add(product);
          } catch (e) {
            print('Error processing individual product: $e');
            print('Problematic product JSON: $productJson');
          }
        }

        return processedProducts;
      } else {
        throw Exception('Failed to load store products: ${response.body}');
      }
    } catch (e) {
      print('Error in getProductsByStore: $e');
      throw Exception('Failed to load store products: $e');
    }
  }
}
