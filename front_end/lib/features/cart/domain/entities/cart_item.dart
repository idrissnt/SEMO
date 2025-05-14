class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final String unit;
  
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
  });
  
  double get totalPrice => price * quantity;
  
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
    String? unit,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
