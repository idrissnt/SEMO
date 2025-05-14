import 'cart_item.dart';

class Cart {
  final List<CartItem> items;
  final double deliveryFee;
  final double minimumOrderValue;
  
  const Cart({
    required this.items,
    this.deliveryFee = 3.99,
    this.minimumOrderValue = 10.0,
  });
  
  double get subtotal => items.fold(
    0, (sum, item) => sum + item.totalPrice
  );
  
  bool get qualifiesForFreeDelivery => subtotal >= minimumOrderValue;
  
  double get deliveryFeeToApply => qualifiesForFreeDelivery ? 0.0 : deliveryFee;
  
  double get total => subtotal + deliveryFeeToApply;
  
  double get progressToFreeDelivery => 
    subtotal >= minimumOrderValue ? 1.0 : subtotal / minimumOrderValue;
    
  int get itemCount => items.fold(
    0, (sum, item) => sum + item.quantity
  );
  
  bool get isEmpty => items.isEmpty;
  
  Cart copyWith({
    List<CartItem>? items,
    double? deliveryFee,
    double? minimumOrderValue,
  }) {
    return Cart(
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrderValue: minimumOrderValue ?? this.minimumOrderValue,
    );
  }
}
