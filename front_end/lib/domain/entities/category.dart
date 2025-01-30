import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic>? parentCategory;
  final List<Map<String, dynamic>> subcategories;
  final int totalProducts;
  final String fullPath;
  final List<Map<String, dynamic>> stores;
  final List<Map<String, dynamic>> products;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.parentCategory,
    required this.subcategories,
    required this.totalProducts,
    required this.fullPath,
    required this.stores,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        parentCategory,
        subcategories,
        totalProducts,
        fullPath,
        stores,
        products,
        createdAt,
        updatedAt,
      ];
}
