// Create a mock cart for UI testing
import 'package:semo/features/cart/domain/entities/cart.dart';
import 'package:semo/features/cart/domain/entities/cart_item.dart';

const mockCart = Cart(
  items: [
    CartItem(
      id: '1',
      productId: '1',
      name: 'Test Product',
      price: 9.99,
      quantity: 2,
      imageUrl: 'https://example.com/image.jpg',
      unit: 'kg',
    ),
  ],
  minimumOrderValue: 30.0,
  deliveryFee: 5.0,
);
