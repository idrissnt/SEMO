import '../../core/config/app_config.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String name,
    required String imageUrl,
    required List<double> priceRange,
    required bool isSeasonalProduct,
    required String categoryName,
    required Map<String, dynamic>? parentCategory,
    required int availableStoreCount,
    required List<Map<String, dynamic>> stores,
    required String description,
    required String unit,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          priceRange: priceRange,
          isSeasonalProduct: isSeasonalProduct,
          categoryName: categoryName,
          parentCategory: parentCategory,
          availableStoreCount: availableStoreCount,
          stores: stores,
          description: description,
          unit: unit,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image_url']?.toString() ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${AppConfig.mediaBaseUrl}$imageUrl';
    }

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      imageUrl: imageUrl,
      priceRange: (json['price_range'] as List<dynamic>?)
              ?.map((e) => double.parse(e.toString()))
              .toList() ??
          [0.0, 0.0],
      isSeasonalProduct: json['is_seasonal'] ?? false,
      categoryName: json['category_name'] ?? '',
      parentCategory: json['parent_category'],
      availableStoreCount: json['available_store_count'] ?? 0,
      stores: (json['stores'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      description: json['description'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price_range': priceRange,
      'is_seasonal': isSeasonalProduct,
      'category_name': categoryName,
      'parent_category': parentCategory,
      'available_store_count': availableStoreCount,
      'stores': stores,
      'description': description,
      'unit': unit,
    };
  }
}
