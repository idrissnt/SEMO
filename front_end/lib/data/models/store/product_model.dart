import 'package:semo/domain/entities/stores/product.dart';

import '../../../core/config/app_config.dart';

class ProductModel extends Product {
  final String subcategory;
  final String quantity;
  final double price;

  const ProductModel({
    required String id,
    required String name,
    required String imageUrl,
    List<double>? priceRange,
    required bool isSeasonalProduct,
    required String categoryName,
    required Map<String, dynamic>? parentCategory,
    int? availableStoreCount,
    required List<Map<String, dynamic>> stores,
    required String description,
    required String? unit,
    this.subcategory = '',
    this.quantity = '',
    this.price = 0.0,
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
          .toList(),
      isSeasonalProduct: json['is_seasonal'] ?? false,
      categoryName: json['category_name'] ?? '',
      parentCategory: json['parent_category'],
      availableStoreCount: json['available_store_count'],
      stores: (json['stores'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      description: json['description'] ?? '',
      unit: json['unit'],
      subcategory: json['subcategory']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
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
      'subcategory': subcategory,
      'quantity': quantity,
      'price': price,
    };
  }

  // Add a copyWith method for easier modification
  ProductModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<double>? priceRange,
    bool? isSeasonalProduct,
    String? categoryName,
    Map<String, dynamic>? parentCategory,
    int? availableStoreCount,
    List<Map<String, dynamic>>? stores,
    String? description,
    String? unit,
    String? subcategory,
    String? quantity,
    double? price,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      priceRange: priceRange ?? this.priceRange,
      isSeasonalProduct: isSeasonalProduct ?? this.isSeasonalProduct,
      categoryName: categoryName ?? this.categoryName,
      parentCategory: parentCategory ?? this.parentCategory,
      availableStoreCount: availableStoreCount ?? this.availableStoreCount,
      stores: stores ?? this.stores,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      subcategory: subcategory ?? this.subcategory,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
