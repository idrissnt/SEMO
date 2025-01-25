import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  RecipeModel({
    required int id,
    required String name,
    required String imageUrl,
    required int preparationTime,
    required String difficulty,
    required List<String> ingredients,
    required String instructions,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          preparationTime: preparationTime,
          difficulty: difficulty,
          ingredients: ingredients,
          instructions: instructions,
        );

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      preparationTime: json['preparation_time'],
      difficulty: json['difficulty'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'preparation_time': preparationTime,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
}
