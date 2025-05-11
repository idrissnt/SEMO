/// This file contains dummy data for testing the community shopping feature

/// A model representing a community shopping order
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
  });
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
      storeLogoUrl: 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg',
      productImageUrls: [
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/filets-poulet.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/viandes+et+poissons/paves-de-saumon.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/tomates.png',
      ],
      totalItems: 7,
      totalPrice: 35.50,
      reward: 5.0,
      isUrgent: true,
      deliveryTime: 'Aujourd\'hui, 18h-20h',
      deliveryAddress: '15 Rue des Fleurs, 75001 Paris',
      notes: 'Merci de sonner à l\'interphone',
    ),
    CommunityOrder(
      id: 'order2',
      customerName: 'Thomas Dubois',
      customerImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      distanceKm: 1.2,
      storeName: 'Lidl',
      storeLogoUrl: 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
      productImageUrls: [
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/pommes.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/bananes.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/fruits+et+legumes/radis.png',
      ],
      totalItems: 5,
      totalPrice: 22.75,
      reward: 3.0,
      isUrgent: false,
      deliveryTime: 'Demain, 10h-12h',
      deliveryAddress: '8 Avenue Victor Hugo, 75016 Paris',
    ),
    CommunityOrder(
      id: 'order3',
      customerName: 'Émilie Rousseau',
      customerImageUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      distanceKm: 0.5,
      storeName: 'E.Leclerc',
      storeLogoUrl: 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/E-Leclerc-logo-for-cart.png',
      productImageUrls: [
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-orange.png',
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/products/shared-product/jus/jus-pomme.png',
      ],
      totalItems: 4,
      totalPrice: 18.20,
      reward: 2.5,
      isUrgent: true,
      deliveryTime: 'Aujourd\'hui, 16h-18h',
      deliveryAddress: '23 Rue de la Paix, 75002 Paris',
      notes: 'Laisser devant la porte si absence',
    ),
    CommunityOrder(
      id: 'order4',
      customerName: 'Lucas Bernard',
      customerImageUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
      distanceKm: 1.5,
      storeName: 'Carrefour',
      storeLogoUrl: 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg',
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
    ),
    CommunityOrder(
      id: 'order5',
      customerName: 'Marie Lefevre',
      customerImageUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
      distanceKm: 0.9,
      storeName: 'Lidl',
      storeLogoUrl: 'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
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
    ),
  ];
}
