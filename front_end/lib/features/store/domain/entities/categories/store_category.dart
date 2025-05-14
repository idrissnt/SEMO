/// Domain entity representing a store category
class StoreCategory {
  /// Unique identifier for the category
  final String id;
  
  /// Name of the category
  final String name;
  
  /// URL of the category image
  final String imageUrl;
  
  /// Description of the category (optional)
  final String? description;
  
  /// List of subcategories in this category
  final List<StoreSubcategory> subcategories;
  
  /// Creates a new store category
  StoreCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    required this.subcategories,
  });
}

/// Domain entity representing a store subcategory
class StoreSubcategory {
  /// Unique identifier for the subcategory
  final String id;
  
  /// ID of the parent category
  final String categoryId;
  
  /// Name of the subcategory
  final String name;
  
  /// URL of the subcategory image
  final String imageUrl;
  
  /// Description of the subcategory (optional)
  final String? description;
  
  /// List of products in this subcategory
  final List<CategoryProduct> products;
  
  /// Creates a new store subcategory
  StoreSubcategory({
    required this.id,
    required this.categoryId,
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
