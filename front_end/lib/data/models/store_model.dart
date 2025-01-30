// ignore_for_file: prefer_const_constructors_in_immutables

import '../../domain/entities/store.dart';

class StoreModel extends Store {
  final String? logoUrl;

  StoreModel({
    required String id,
    required String name,
    String? description,
    double? rating,
    bool? isOpen,
    double? distance,
    int? estimatedTime,
    String? address,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
    // New fields from backend
    int? totalProducts,
    bool? isBigStore,
    String? deliveryType,
    bool? isCurrentlyOpen,
    double? deliveryFee,
    double? minimumOrder,
    double? freeDeliveryThreshold,
    int? totalReviews,
    this.logoUrl,
  }) : super(
          id: id,
          name: name,
          description: description,
          rating: rating,
          isOpen: isOpen,
          distance: distance,
          estimatedTime: estimatedTime,
          address: address,
          categories: categories,
          products: products,
          createdAt: createdAt,
          updatedAt: updatedAt,
          // Additional fields
          totalProducts: totalProducts,
          isBigStore: isBigStore,
          deliveryType: deliveryType,
          isCurrentlyOpen: isCurrentlyOpen,
          deliveryFee: deliveryFee,
          minimumOrder: minimumOrder,
          freeDeliveryThreshold: freeDeliveryThreshold,
          totalReviews: totalReviews,
        );

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Store',
      description: json['description'],
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : null,
      isOpen: json['is_open'],
      distance: json['distance'] != null
          ? double.parse(json['distance'].toString())
          : null,
      estimatedTime: json['estimated_time'],
      address: json['address'],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      // New fields from backend
      totalProducts: json['total_products'],
      isBigStore: json['is_big_store'],
      deliveryType: json['delivery_type'],
      isCurrentlyOpen: json['is_currently_open'],
      deliveryFee: json['delivery_fee'] != null
          ? double.parse(json['delivery_fee'].toString())
          : null,
      minimumOrder: json['minimum_order'] != null
          ? double.parse(json['minimum_order'].toString())
          : null,
      freeDeliveryThreshold: json['free_delivery_threshold'] != null
          ? double.parse(json['free_delivery_threshold'].toString())
          : null,
      totalReviews: json['total_reviews'],
      logoUrl: json['logo_url'],
    );
  }

  factory StoreModel.fromEntity(Store store) {
    if (store is StoreModel) {
      return store;
    }

    return StoreModel(
      id: store.id,
      name: store.name,
      description: store.description,
      rating: store.rating,
      isOpen: store.isOpen,
      distance: store.distance,
      estimatedTime: store.estimatedTime,
      address: store.address,
      categories: store.categories,
      products: store.products,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
      totalProducts: store.totalProducts,
      isBigStore: store.isBigStore,
      deliveryType: store.deliveryType,
      isCurrentlyOpen: store.isCurrentlyOpen,
      deliveryFee: store.deliveryFee,
      minimumOrder: store.minimumOrder,
      freeDeliveryThreshold: store.freeDeliveryThreshold,
      totalReviews: store.totalReviews,
      logoUrl: store is StoreModel ? store.logoUrl : null,
    );
  }

  factory StoreModel.toModel(Store store) {
    return StoreModel(
      id: store.id,
      name: store.name,
      description: store.description,
      rating: store.rating,
      isOpen: store.isOpen,
      distance: store.distance,
      estimatedTime: store.estimatedTime,
      address: store.address,
      categories: store.categories,
      products: store.products,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
      totalProducts: store.totalProducts,
      isBigStore: store.isBigStore,
      deliveryType: store.deliveryType,
      isCurrentlyOpen: store.isCurrentlyOpen,
      deliveryFee: store.deliveryFee,
      minimumOrder: store.minimumOrder,
      freeDeliveryThreshold: store.freeDeliveryThreshold,
      totalReviews: store.totalReviews,
      logoUrl: store.logoUrl,
    );
  }

  factory StoreModel.fromStore(Store store) {
    return StoreModel(
      id: store.id,
      name: store.name,
      description: store.description,
      logoUrl: store.logoUrl,
      rating: store.rating,
      isOpen: store.isOpen,
      distance: store.distance,
      estimatedTime: store.estimatedTime,
      address: store.address,
      categories: store.categories,
      products: store.products,
      createdAt: store.createdAt,
      updatedAt: store.updatedAt,
      totalProducts: store.totalProducts,
      isBigStore: store.isBigStore,
      deliveryType: store.deliveryType,
      isCurrentlyOpen: store.isCurrentlyOpen,
      deliveryFee: store.deliveryFee,
      minimumOrder: store.minimumOrder,
      freeDeliveryThreshold: store.freeDeliveryThreshold,
      totalReviews: store.totalReviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Basic store information
      'id': id,
      'name': name,
      'description': description,

      // Image URLs
      'logo_url': logoUrl,

      // Ratings and status
      'rating': rating,
      'is_open': isOpen,
      'total_reviews': totalReviews,

      // Location and distance
      'distance': distance,
      'estimated_time': estimatedTime,
      'address': address,

      // Additional store details
      'total_products': totalProducts,
      'is_big_store': isBigStore,
      'delivery_type': deliveryType,
      'is_currently_open': isCurrentlyOpen,
      'delivery_fee': deliveryFee,
      'minimum_order': minimumOrder,
      'free_delivery_threshold': freeDeliveryThreshold,

      // Nested data
      'categories': categories,
      'products': products,

      // Timestamps
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
