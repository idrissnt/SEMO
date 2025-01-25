// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/services/auth_service.dart';
import '../models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final http.Client client;
  final AuthService? authService;

  StoreRepositoryImpl({
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
  Future<List<Store>> getNearbyStores() async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/stores/nearby/';
      print('Fetching Nearby Stores URL: $url');
      print('Nearby Stores Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Nearby Stores Response Status: ${response.statusCode}');
      print('Nearby Stores Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StoreModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load nearby stores: ${response.body}');
      }
    } catch (e) {
      print('Error in getNearbyStores: $e');
      throw Exception('Failed to load nearby stores: $e');
    }
  }

  @override
  Future<List<Store>> getPopularStores() async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/stores/popular/';
      print('Fetching Popular Stores URL: $url');
      print('Popular Stores Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Popular Stores Response Status: ${response.statusCode}');
      print('Popular Stores Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StoreModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular stores: ${response.body}');
      }
    } catch (e) {
      print('Error in getPopularStores: $e');
      throw Exception('Failed to load popular stores: $e');
    }
  }

  @override
  Future<Store> getStoreById(int id) async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/stores/$id/';
      print('Fetching Store by ID URL: $url');
      print('Store by ID Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Store by ID Response Status: ${response.statusCode}');
      print('Store by ID Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return StoreModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load store: ${response.body}');
      }
    } catch (e) {
      print('Error in getStoreById: $e');
      throw Exception('Failed to load store: $e');
    }
  }

  @override
  Future<List<Store>> searchStores(String query) async {
    try {
      final headers = await _getHeaders();
      final url = '${AppConfig.apiBaseUrl}/stores/search/?q=$query';
      print('Searching Stores URL: $url');
      print('Searching Stores Headers: $headers');

      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Searching Stores Response Status: ${response.statusCode}');
      print('Searching Stores Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StoreModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search stores: ${response.body}');
      }
    } catch (e) {
      print('Error in searchStores: $e');
      throw Exception('Failed to search stores: $e');
    }
  }
}
