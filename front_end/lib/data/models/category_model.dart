import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required String id,
    required String name,
    required String description,
    required Map<String, dynamic>? parentCategory,
    required List<Map<String, dynamic>> subcategories,
    required int totalProducts,
    required String fullPath,
    required List<Map<String, dynamic>> stores,
    required List<Map<String, dynamic>> products,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          description: description,
          parentCategory: parentCategory,
          subcategories: subcategories,
          totalProducts: totalProducts,
          fullPath: fullPath,
          stores: stores,
          products: products,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      parentCategory: json['parent_category'],
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      totalProducts: json['total_products'] ?? 0,
      fullPath: json['full_path'] ?? '',
      stores: (json['stores'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parent_category': parentCategory,
      'subcategories': subcategories,
      'total_products': totalProducts,
      'full_path': fullPath,
      'stores': stores,
      'products': products,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
