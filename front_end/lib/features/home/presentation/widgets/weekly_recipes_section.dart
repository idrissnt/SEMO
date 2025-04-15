import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';

import '../../../../core/utils/logger.dart';

class WeeklyRecipesSection extends StatelessWidget {
  final String title;
  final List<Recipe> recipes;

  final AppLogger _logger = AppLogger();

  WeeklyRecipesSection({
    Key? key,
    required this.title,
    required this.recipes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  _logger.debug('Show more recipes button pressed');
                  // Navigate to recipes page
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220, // Further reduced height to fit content perfectly
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: recipes.length + 1, // +1 for the add new recipe card
            itemBuilder: (context, index) {
              if (index == recipes.length) {
                // Last item is "Add New Recipe" card
                return AddNewRecipeCard(
                  onTap: () {
                    _logger.info('Add new recipe tapped');
                    // Navigate to add recipe page
                  },
                );
              } else {
                // Recipe cards
                final recipe = recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onEditTap: () {
                    _logger.info('Edit recipe tapped: ${recipe.name}');
                    // Navigate to edit recipe page
                  },
                  onAddToCartTap: () {
                    _logger.info('Add ingredients to cart: ${recipe.name}');
                    // Add ingredients to cart logic
                  },
                );
              }
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class AddNewRecipeCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddNewRecipeCard({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 24,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ajouter une recette',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onEditTap;
  final VoidCallback onAddToCartTap;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.onEditTap,
    required this.onAddToCartTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // View recipe details
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Image with day of week and edit button overlay
                Stack(
                  children: [
                    // Recipe Image
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: SizedBox(
                        height: 120, // Reduced image height
                        width: double.infinity,
                        child: recipe.imageUrl != null
                            ? Image.network(
                                recipe.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.restaurant,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Gradient overlay for better text visibility
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Day of week and Edit button
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              recipe.dayOfWeek,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: onEditTap,
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Recipe name
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Add to cart button
                Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 8.0, top: 2.0),
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onAddToCartTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ajouter ingrédients',
                            style: TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.shopping_cart, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final String dayOfWeek;
  final String? imageUrl;
  final List<String> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.dayOfWeek,
    this.imageUrl,
    required this.ingredients,
  });
}

// Sample data for recipes
List<Recipe> getSampleRecipes() {
  return [
    Recipe(
      id: '1',
      name: 'Spaghetti Bolognaise',
      dayOfWeek: 'Lundi',
      imageUrl:
          'https://images.unsplash.com/photo-1551892374-ecf8754cf8b0?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      ingredients: ['Pâtes', 'Viande hachée', 'Tomates', 'Oignons', 'Ail'],
    ),
    Recipe(
      id: '2',
      name: 'Poulet rôti aux légumes',
      dayOfWeek: 'Mardi',
      imageUrl:
          'https://images.unsplash.com/photo-1532550907401-a500c9a57435?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      ingredients: ['Poulet', 'Pommes de terre', 'Carottes', 'Oignons', 'Thym'],
    ),
    Recipe(
      id: '3',
      name: 'Salade César',
      dayOfWeek: 'Mercredi',
      imageUrl:
          'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      ingredients: [
        'Laitue romaine',
        'Poulet',
        'Parmesan',
        'Croûtons',
        'Sauce César'
      ],
    ),
    Recipe(
      id: '4',
      name: 'Risotto aux champignons',
      dayOfWeek: 'Jeudi',
      imageUrl:
          'https://images.unsplash.com/photo-1476124369491-e7addf5db371?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      ingredients: [
        'Riz arborio',
        'Champignons',
        'Oignons',
        'Bouillon',
        'Parmesan'
      ],
    ),
    Recipe(
      id: '5',
      name: 'Poisson au four',
      dayOfWeek: 'Vendredi',
      imageUrl:
          'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      ingredients: [
        'Filet de poisson',
        'Citron',
        'Herbes',
        'Huile d\'olive',
        'Ail'
      ],
    ),
    Recipe(
      id: '6',
      name: 'Pizza maison',
      dayOfWeek: 'Samedi',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      ingredients: [
        'Pâte à pizza',
        'Sauce tomate',
        'Mozzarella',
        'Jambon',
        'Champignons'
      ],
    ),
    Recipe(
      id: '7',
      name: 'Ratatouille',
      dayOfWeek: 'Dimanche',
      imageUrl:
          'https://images.unsplash.com/photo-1572453800999-e8d2d1589b7c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      ingredients: [
        'Aubergines',
        'Courgettes',
        'Poivrons',
        'Tomates',
        'Oignons'
      ],
    ),
  ];
}
