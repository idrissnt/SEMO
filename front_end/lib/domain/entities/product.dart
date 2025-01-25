class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final bool isSeasonalProduct;
  final String? season;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.isSeasonalProduct,
    this.season,
    required this.description,
  });
}
