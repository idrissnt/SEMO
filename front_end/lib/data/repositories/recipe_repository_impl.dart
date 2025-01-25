import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/services/auth_service.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final http.Client client;
  final AuthService? authService;

  RecipeRepositoryImpl({
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
  Future<List<Recipe>> getPopularRecipes() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/recipes/popular/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular recipes');
      }
    } catch (e) {
      throw Exception('Failed to load popular recipes: $e');
    }
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/recipes/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return RecipeModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load recipe');
      }
    } catch (e) {
      throw Exception('Failed to load recipe: $e');
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/recipes/search/?q=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search recipes');
      }
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }

  @override
  Future<List<Recipe>> getSeasonalRecipes() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('${AppConfig.apiBaseUrl}/recipes/seasonal/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RecipeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load seasonal recipes');
      }
    } catch (e) {
      throw Exception('Failed to load seasonal recipes: $e');
    }
  }
}
