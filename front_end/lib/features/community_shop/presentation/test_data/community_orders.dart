/// This file contains dummy data for testing the community shopping feature

/// A model representing a community shopping order
import 'package:semo/features/community_shop/domain/enums/order_state.dart';

class CommunityOrder {
  final String id;
  final String customerName;
  final String customerImageUrl;
  final double distanceKm;
  final String storeName;
  final String storeLogoUrl;
  final List<String> productImageUrls;
  final int totalItems;
  final double totalPrice;
  final double reward;
  final bool isUrgent;
  final String deliveryTime;
  final String deliveryAddress;
  final String notes;
  final String storeAddress;

  // New field for order state - not final so it can be changed
  OrderState state;

  CommunityOrder({
    required this.id,
    required this.customerName,
    required this.customerImageUrl,
    required this.distanceKm,
    required this.storeName,
    required this.storeLogoUrl,
    required this.productImageUrls,
    required this.totalItems,
    required this.totalPrice,
    required this.reward,
    required this.isUrgent,
    required this.deliveryTime,
    required this.deliveryAddress,
    this.notes = '',
    required this.storeAddress,
    this.state = OrderState.scheduled,
  });

  // Method to create a copy with updated state
  CommunityOrder copyWith({OrderState? state}) {
    return CommunityOrder(
      id: id,
      customerName: customerName,
      customerImageUrl: customerImageUrl,
      distanceKm: distanceKm,
      storeName: storeName,
      storeLogoUrl: storeLogoUrl,
      productImageUrls: productImageUrls,
      totalItems: totalItems,
      totalPrice: totalPrice,
      reward: reward,
      isUrgent: isUrgent,
      deliveryTime: deliveryTime,
      deliveryAddress: deliveryAddress,
      notes: notes,
      storeAddress: storeAddress,
      state: state ?? this.state,
    );
  }
}

/// Get sample community orders for testing
List<CommunityOrder> getSampleCommunityOrders() {
  return [
    CommunityOrder(
      id: 'order1',
      customerName: 'Sophie Martin',
      customerImageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      distanceKm: 0.8,
      storeName: 'Carrefour',
      storeLogoUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg',
      productImageUrls: [
        'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'
      ],
      totalItems: 7,
      totalPrice: 35.50,
      reward: 5.0,
      isUrgent: true,
      deliveryTime: 'Aujourd\'hui, 18h-20h',
      deliveryAddress: '11 avenue du charmois vandoeuvre les Nancy 54500',
      notes: 'Merci de sonner à l\'interphone',
      storeAddress: '43 rue de Saurupt 54000 Nancy',
    ),
    CommunityOrder(
      id: 'order2',
      customerName: 'Thomas Dubois',
      customerImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      distanceKm: 1.2,
      storeName: 'Lidl',
      storeLogoUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
      productImageUrls: [
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/pommes.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/bananes.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/radis.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/filets-poulet.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/paves-de-saumon.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/tomates.png',
      ],
      totalItems: 5,
      totalPrice: 22.75,
      reward: 3.0,
      isUrgent: false,
      deliveryTime: 'Demain, 10h-12h',
      deliveryAddress: '8 Avenue Victor Hugo, 75016 Paris',
      storeAddress: '8 Avenue Victor Hugo, 75016 Paris',
    ),
    CommunityOrder(
      id: 'order3',
      customerName: 'Émilie Rousseau',
      customerImageUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      distanceKm: 0.5,
      storeName: 'E.Leclerc',
      storeLogoUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/E-Leclerc-logo-for-cart.png',
      productImageUrls: [
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-orange.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-pomme.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/filets-poulet.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/paves-de-saumon.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/tomates.png',
      ],
      totalItems: 4,
      totalPrice: 18.20,
      reward: 2.5,
      isUrgent: true,
      deliveryTime: 'Aujourd\'hui, 16h-18h',
      deliveryAddress: '11 avenue du charmois vandoeuvre les Nancy 54500',
      notes: 'Laisser devant la porte si absence',
      storeAddress: '43 rue de Saurupt 54000 Nancy',
    ),
    CommunityOrder(
      id: 'order4',
      customerName: 'Lucas Bernard',
      customerImageUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
      distanceKm: 1.5,
      storeName: 'Carrefour',
      storeLogoUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg',
      productImageUrls: [
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/viande-hachee.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/saucisson.png',
      ],
      totalItems: 3,
      totalPrice: 28.90,
      reward: 4.0,
      isUrgent: false,
      deliveryTime: 'Demain, 14h-16h',
      deliveryAddress: '42 Boulevard Haussmann, 75009 Paris',
      storeAddress: '42 Boulevard Haussmann, 75009 Paris',
    ),
    CommunityOrder(
      id: 'order5',
      customerName: 'Marie Lefevre',
      customerImageUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
      distanceKm: 0.9,
      storeName: 'Lidl',
      storeLogoUrl:
          'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
      productImageUrls: [
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/carottes.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/oignons.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/pommes-de-terre.png',
      ],
      totalItems: 8,
      totalPrice: 19.75,
      reward: 3.5,
      isUrgent: true,
      deliveryTime: 'Aujourd\'hui, 19h-21h',
      deliveryAddress: '11 Rue Saint-Denis, 75001 Paris',
      notes: 'Appeler 10 minutes avant l\'arrivée',
      storeAddress: '11 Rue Saint-Denis, 75001 Paris',
    ),
  ];
}
