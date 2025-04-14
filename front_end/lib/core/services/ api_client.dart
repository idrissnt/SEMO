// example simple api client

import 'package:dio/dio.dart';

class ProductApiClient {
  final Dio _dio;

  ProductApiClient(this._dio);

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await _dio.get('/products');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }
}
