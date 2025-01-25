import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getPopularRecipes();
  Future<Recipe> getRecipeById(int id);
  Future<List<Recipe>> searchRecipes(String query);
  Future<List<Recipe>> getSeasonalRecipes();
}
