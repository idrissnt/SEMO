/// Domain entity representing a basic product
class Product {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final double price;
  final double pricePerUnit;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.pricePerUnit,
    required this.imageUrl,
  });

  @override
  String toString() => '$name ($quantity $unit)';
}

/// Domain entity representing a product with store, category and price details
class ProductWithDetails {
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

  const ProductWithDetails({
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

  /// Extract the basic product information
  Product toSimpleProduct() {
    return Product(
      id: productId,
      name: productName,
      quantity: quantity,
      unit: unit,
      price: price,
      pricePerUnit: pricePerUnit,
      imageUrl: imageUrl,
    );
  }
}
