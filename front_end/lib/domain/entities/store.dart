class Store {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final bool isOpen;
  final double? distance;
  final int? estimatedTime;
  final String address;

  Store({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.isOpen,
    this.distance,
    this.estimatedTime,
    required this.address,
  });
}
