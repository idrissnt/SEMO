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
  /// Unique identifier for the product
  final String id;

  /// Name of the product
  final String name;

  /// URL of the product image
  final String imageUrl;

  /// Price of the product
  final double price;

  /// Original price before discount (optional)
  final double? originalPrice;

  /// Unit of measurement (e.g., kg, piece)
  final String unit;

  /// Whether the product is in stock
  final bool inStock;

  /// Description of the product (optional)
  final String? description;

  /// Creates a new category product
  CategoryProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.unit,
    this.inStock = true,
    this.description,
  });
}
