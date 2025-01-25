// ignore_for_file: avoid_print

import '../entities/store.dart';
import '../entities/recipe.dart';
import '../entities/product.dart';
import '../repositories/store_repository.dart';
import '../repositories/recipe_repository.dart';
import '../repositories/product_repository.dart';

class GetHomeDataUseCase {
  final StoreRepository storeRepository;
  final RecipeRepository recipeRepository;
  final ProductRepository productRepository;

  GetHomeDataUseCase({
    required this.storeRepository,
    required this.recipeRepository,
    required this.productRepository,
  });

  Future<HomeData> execute() async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        storeRepository.getNearbyStores().catchError((e) {
          print('Error fetching nearby stores: $e');
          return <Store>[];
        }),
        storeRepository.getPopularStores().catchError((e) {
          print('Error fetching popular stores: $e');
          return <Store>[];
        }),
        recipeRepository.getPopularRecipes().catchError((e) {
          print('Error fetching popular recipes: $e');
          return <Recipe>[];
        }),
        productRepository.getSeasonalProducts().catchError((e) {
          print('Error fetching seasonal products: $e');
          return <Product>[];
        }),
      ]);

      return HomeData(
        nearbyStores: results[0] as List<Store>,
        popularStores: results[1] as List<Store>,
        popularRecipes: results[2] as List<Recipe>,
        seasonalProducts: results[3] as List<Product>,
      );
    } catch (e) {
      print('Error in GetHomeDataUseCase: $e');
      // Return empty lists if there's an error
      return HomeData(
        nearbyStores: [],
        popularStores: [],
        popularRecipes: [],
        seasonalProducts: [],
      );
    }
  }
}

class HomeData {
  final List<Store> nearbyStores;
  final List<Store> popularStores;
  final List<Recipe> popularRecipes;
  final List<Product> seasonalProducts;

  HomeData({
    required this.nearbyStores,
    required this.popularStores,
    required this.popularRecipes,
    required this.seasonalProducts,
  });
}
