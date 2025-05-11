/// Sample data for popular products
/// This file contains dummy data for testing the popular products feature

/// A store with its popular products
class StoreWithCategoryProducts {
  final String id;
  final String name;
  final String logo;
  final String category;
  final List<PopularProduct> products;

  StoreWithCategoryProducts({
    required this.id,
    required this.name,
    required this.logo,
    required this.category,
    required this.products,
  });
}

/// A popular product model for testing
class PopularProduct {
  final String id;
  final String name;
  final double productPrice;
  final String productUnit;
  final String imageUrl;
  final double pricePerUnit;
  final String baseUnit;
  final String storeId;

  PopularProduct({
    required this.id,
    required this.name,
    required this.productPrice,
    required this.productUnit,
    required this.imageUrl,
    required this.pricePerUnit,
    required this.baseUnit,
    required this.storeId,
  });

  /// Convert to a map for the PopularProductsSection widget
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'productPrice': productPrice,
      'productUnit': productUnit,
      'imageUrl': imageUrl,
      'pricePerUnit': pricePerUnit,
      'baseUnit': baseUnit,
      'storeId': storeId,
    };
  }
}

/// Get sample stores with their popular products
List<StoreWithCategoryProducts> getSampleStoresWithCategoryProducts() {
  return [
    StoreWithCategoryProducts(
      id: 'Lidl',
      name: 'Lidl',
      logo:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
      category: 'Fruits & légumes',
      products: _getLidlFruitAndVegetableProducts(),
    ),
    StoreWithCategoryProducts(
      id: 'carrefour',
      name: 'Carrefour',
      logo:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg',
      category: 'Viandes & Poisson',
      products: _getCarrefourMeatAndFishProducts(),
    ),
    StoreWithCategoryProducts(
      id: 'E.Leclerc',
      name: 'E.Leclerc',
      logo:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/E-Leclerc-logo-for-cart.png',
      category: 'Produits laitiers',
      products: _getELeclercMilkProducts(),
    ),
  ];
}

/// Get popular products for Carrefour
List<PopularProduct> _getCarrefourMeatAndFishProducts() {
  return [
    PopularProduct(
      id: 'c1',
      name: 'Filets de poulet',
      productPrice: 12,
      productUnit: 'kg',
      pricePerUnit: 12,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/filets-poulet.png',
      baseUnit: 'kg',
      storeId: 'carrefour',
    ),
    PopularProduct(
      id: 'c2',
      name: 'Paves de saumon',
      productPrice: 9.89,
      productUnit: '460 g',
      pricePerUnit: 20.78,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/paves-de-saumon.png',
      baseUnit: 'kg',
      storeId: 'carrefour',
    ),
    PopularProduct(
      id: 'c3',
      name: 'Pilon de poulet',
      productPrice: 5.5,
      productUnit: '500 g',
      pricePerUnit: 11,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/pilon-poulet.png',
      baseUnit: 'kg',
      storeId: 'carrefour',
    ),
    PopularProduct(
      id: 'c4',
      name: 'Saucisson',
      productPrice: 12,
      productUnit: '500g',
      pricePerUnit: 24,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/saucisson.png',
      baseUnit: 'kg',
      storeId: 'carrefour',
    ),
    PopularProduct(
      id: 'c5',
      name: 'Viande hachée',
      productPrice: 6,
      productUnit: '250g',
      pricePerUnit: 24,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/viande-hachee.png',
      baseUnit: 'kg',
      storeId: 'carrefour',
    ),
  ];
}

/// Get popular products for Lidl
List<PopularProduct> _getLidlFruitAndVegetableProducts() {
  return [
    PopularProduct(
      id: 'l1',
      name: 'Avocat',
      productPrice: 2.99,
      productUnit: 'unité',
      pricePerUnit: 2.99,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruit-and-vegetables/Avocat.png',
      baseUnit: 'unité',
      storeId: 'Lidl',
    ),
    PopularProduct(
      id: 'l2',
      name: 'Banane',
      productPrice: 4.50,
      productUnit: '500g',
      pricePerUnit: 9,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruit-and-vegetables/Banane.png',
      baseUnit: 'kg',
      storeId: 'Lidl',
    ),
    PopularProduct(
      id: 'l3',
      name: 'Brocoli',
      productPrice: 3.99,
      productUnit: '500g',
      pricePerUnit: 7.98,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruit-and-vegetables/Brocoli.png',
      baseUnit: 'kg',
      storeId: 'Lidl',
    ),
    PopularProduct(
      id: 'l4',
      name: 'Carotte',
      productPrice: 2.20,
      productUnit: '250g',
      pricePerUnit: 8.80,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruit-and-vegetables/Carotte.png',
      baseUnit: 'kg',
      storeId: 'Lidl',
    ),
    PopularProduct(
      id: 'l5',
      name: 'Tomate',
      productPrice: 2.49,
      productUnit: '100g',
      pricePerUnit: 24.90,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruit-and-vegetables/Tomate.png',
      baseUnit: 'kg',
      storeId: 'Lidl',
    ),
  ];
}

/// Get popular products for E.Leclerc
List<PopularProduct> _getELeclercMilkProducts() {
  return [
    PopularProduct(
      id: 'f1',
      name: 'Jus d\'Ananas',
      productPrice: 0.99,
      productUnit: 'litre',
      pricePerUnit: 0.99,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-ananas.png',
      baseUnit: 'litre',
      storeId: 'E.Leclerc',
    ),
    PopularProduct(
      id: 'f2',
      name: 'Jus de Citron',
      productPrice: 1.79,
      productUnit: 'litre',
      pricePerUnit: 1.79,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-citron.png',
      baseUnit: 'litre',
      storeId: 'E.Leclerc',
    ),
    PopularProduct(
      id: 'f3',
      name: 'Jus d\'Orange',
      productPrice: 2.99,
      productUnit: 'litre',
      pricePerUnit: 2.99,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-orange.png',
      baseUnit: 'litre',
      storeId: 'E.Leclerc',
    ),
    PopularProduct(
      id: 'f4',
      name: 'Jus de Pomme',
      productPrice: 3.49,
      productUnit: 'litre',
      pricePerUnit: 3.49,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-pomme.png',
      baseUnit: 'litre',
      storeId: 'E.Leclerc',
    ),
    PopularProduct(
      id: 'f5',
      name: 'Jus orange 2',
      productPrice: 1.29,
      productUnit: 'litre',
      pricePerUnit: 1.29,
      imageUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-orange-2.png',
      baseUnit: 'litre',
      storeId: 'E.Leclerc',
    ),
  ];
}
