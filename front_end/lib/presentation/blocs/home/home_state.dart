import '../../../domain/entities/store.dart';
import '../../../domain/entities/recipe.dart';
import '../../../domain/entities/product.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Store> nearbyStores;
  final List<Store> popularStores;
  final List<Recipe> popularRecipes;
  final List<Product> seasonalProducts;

  HomeLoaded({
    required this.nearbyStores,
    required this.popularStores,
    required this.popularRecipes,
    required this.seasonalProducts,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
