class Recipe {
  final int id;
  final String name;
  final String imageUrl;
  final int preparationTime;
  final String difficulty;
  final List<String> ingredients;
  final String instructions;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.preparationTime,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
  });
}
