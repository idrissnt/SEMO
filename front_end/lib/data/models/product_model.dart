import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required int id,
    required String name,
    required String imageUrl,
    required double price,
    required bool isSeasonalProduct,
    String? season,
    required String description,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          price: price,
          isSeasonalProduct: isSeasonalProduct,
          season: season,
          description: description,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      imageUrl: json['image_url'] ?? '',
      price: double.parse(json['price']?.toString() ?? '0.0'),
      isSeasonalProduct: json['is_seasonal'] ?? false,
      season: json['category'], // Using category as season since season is not provided
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'is_seasonal_product': isSeasonalProduct,
      'season': season ?? '',
      'description': description,
    };
  }
}
