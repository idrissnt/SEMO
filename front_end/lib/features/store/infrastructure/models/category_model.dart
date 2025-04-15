import '../../domain/entities/category.dart';

/// Data model for Category that handles serialization/deserialization
class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String path;
  final String? description;
  final String storeBrandId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.path,
    required this.storeBrandId,
    this.description,
  });

  /// Creates a CategoryModel from JSON data
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      path: json['path'] ?? '',
      storeBrandId: json['store_brand_id'] ?? '',
      description: json['description'],
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'path': path,
      'store_brand_id': storeBrandId,
      'description': description,
    };
  }

  /// Creates a CategoryModel from a domain entity
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      path: entity.path,
      storeBrandId: entity.storeBrandId,
      description: entity.description,
    );
  }

  /// Converts this model to a domain entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      slug: slug,
      path: path,
      storeBrandId: storeBrandId,
      description: description,
    );
  }
}
