import '../../domain/entities/product.dart';

/// Data model for Product that handles serialization/deserialization
class ProductModel {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final double price;
  final double pricePerUnit;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.pricePerUnit,
    required this.imageUrl,
  });

  /// Creates a ProductModel from JSON data
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      pricePerUnit: (json['price_per_unit'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'] ?? '',
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'price_per_unit': pricePerUnit,
      'image_url': imageUrl,
    };
  }

  /// Creates a ProductModel from a domain entity
  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      price: entity.price,
      pricePerUnit: entity.pricePerUnit,
      imageUrl: entity.imageUrl,
    );
  }

  /// Converts this model to a domain entity
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      quantity: quantity,
      unit: unit,
      price: price,
      pricePerUnit: pricePerUnit,
      imageUrl: imageUrl,
    );
  }
}

/// Data model for ProductWithDetails that handles serialization/deserialization
class ProductWithDetailsModel {
  // Store fields
  final String storeId;
  final String storeName;
  final String storeImageLogo;

  // Category fields
  final String categoryId;
  final String categoryName;
  final String categoryPath;
  final String categorySlug;

  // Product fields
  final String productId;
  final String productName;
  final String productSlug;
  final int quantity;
  final String unit;
  final String description;
  final String imageUrl;
  final String? imageThumbnail;

  // Store product fields
  final double price;
  final double pricePerUnit;
  final String storeProductId;

  ProductWithDetailsModel({
    required this.storeId,
    required this.storeName,
    required this.storeImageLogo,
    required this.categoryId,
    required this.categoryName,
    required this.categoryPath,
    required this.categorySlug,
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.quantity,
    required this.unit,
    required this.description,
    required this.imageUrl,
    this.imageThumbnail,
    required this.price,
    required this.pricePerUnit,
    required this.storeProductId,
  });

  /// Creates a ProductWithDetailsModel from JSON data
  factory ProductWithDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductWithDetailsModel(
      storeId: json['store_brand_id'] ?? '',
      storeName: json['store_brand_name'] ?? '',
      storeImageLogo: json['store_brand_image_logo'] ?? '',
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      categoryPath: json['category_path'] ?? '',
      categorySlug: json['category_slug'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productSlug: json['product_slug'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      imageThumbnail: json['image_thumbnail'],
      price: (json['price'] ?? 0.0).toDouble(),
      pricePerUnit: (json['price_per_unit'] ?? 0.0).toDouble(),
      storeProductId: json['store_product_id'] ?? '',
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'store_brand_id': storeId,
      'store_brand_name': storeName,
      'store_brand_image_logo': storeImageLogo,
      'category_id': categoryId,
      'category_name': categoryName,
      'category_path': categoryPath,
      'category_slug': categorySlug,
      'product_id': productId,
      'product_name': productName,
      'product_slug': productSlug,
      'quantity': quantity,
      'unit': unit,
      'description': description,
      'image_url': imageUrl,
      'image_thumbnail': imageThumbnail,
      'price': price,
      'price_per_unit': pricePerUnit,
      'store_product_id': storeProductId,
    };
  }

  /// Creates a ProductWithDetailsModel from a domain entity
  factory ProductWithDetailsModel.fromEntity(ProductWithDetails entity) {
    return ProductWithDetailsModel(
      storeId: entity.storeId,
      storeName: entity.storeName,
      storeImageLogo: entity.storeImageLogo,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryPath: entity.categoryPath,
      categorySlug: entity.categorySlug,
      productId: entity.productId,
      productName: entity.productName,
      productSlug: entity.productSlug,
      quantity: entity.quantity,
      unit: entity.unit,
      description: entity.description,
      imageUrl: entity.imageUrl,
      imageThumbnail: entity.imageThumbnail,
      price: entity.price,
      pricePerUnit: entity.pricePerUnit,
      storeProductId: entity.storeProductId,
    );
  }

  /// Converts this model to a domain entity
  ProductWithDetails toEntity() {
    return ProductWithDetails(
      storeId: storeId,
      storeName: storeName,
      storeImageLogo: storeImageLogo,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryPath: categoryPath,
      categorySlug: categorySlug,
      productId: productId,
      productName: productName,
      productSlug: productSlug,
      quantity: quantity,
      unit: unit,
      description: description,
      imageUrl: imageUrl,
      imageThumbnail: imageThumbnail,
      price: price,
      pricePerUnit: pricePerUnit,
      storeProductId: storeProductId,
    );
  }
}
