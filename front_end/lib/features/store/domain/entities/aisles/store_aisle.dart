/// Domain entity representing a store category
class StoreAisle {
  /// Unique identifier for the category
  final String id;

  /// Name of the category
  final String name;

  /// URL of the category image
  final String imageUrl;

  /// Description of the category (optional)
  final String? description;

  /// List of categories in this aisle
  final List<AisleCategory> categories;

  /// Creates a new store aisle
  StoreAisle({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    required this.categories,
  });
}

/// Domain entity representing a store category
class AisleCategory {
  /// Unique identifier for the category
  final String id;

  /// ID of the parent aisle
  final String aisleId;

  /// Name of the category
  final String name;

  /// URL of the category image
  final String imageUrl;

  /// Description of the category (optional)
  final String? description;

  /// List of products in this category
  final List<CategoryProduct> products;

  /// Creates a new store category
  AisleCategory({
    required this.id,
    required this.aisleId,
    required this.name,
    required this.imageUrl,
    this.description,
    required this.products,
  });
}

/// Domain entity representing a product in a category
class CategoryProduct {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String productUnit;
  final double pricePerUnit;
  final String unit;
  final String? description;

  CategoryProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.productUnit,
    required this.pricePerUnit,
    required this.unit,
    this.description,
  });
}
