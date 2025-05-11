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
