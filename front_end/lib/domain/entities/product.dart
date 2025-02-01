import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final List<double>? priceRange;
  final bool isSeasonalProduct;
  final String categoryName;
  final Map<String, dynamic>? parentCategory;
  final int? availableStoreCount;
  final List<Map<String, dynamic>> stores;
  final String description;
  final String? unit;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.priceRange,
    required this.isSeasonalProduct,
    required this.categoryName,
    required this.parentCategory,
    this.availableStoreCount,
    required this.stores,
    required this.description,
    required this.unit,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        priceRange,
        isSeasonalProduct,
        categoryName,
        parentCategory,
        availableStoreCount,
        stores,
        description,
        unit,
      ];
}
